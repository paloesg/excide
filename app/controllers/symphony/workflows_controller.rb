class Symphony::WorkflowsController < WorkflowsController
  include Adapter

  before_action :set_clients, only: [:new, :create, :edit, :update]
  before_action :set_workflow, only: [:show, :edit, :update, :destroy, :assign, :section, :reset, :data_entry, :xero_create_invoice_payable]
  before_action :set_attributes_metadata, only: [:create, :update]
  before_action :set_s3_direct_post, only: [:show]
  # before_action :send_email_to_xero, only: [:show]

  rescue_from Xeroizer::OAuth::TokenExpired, Xeroizer::OAuth::TokenInvalid, with: :xero_login

  def index
    template = Template.find(params[:workflow_name])
    @workflows = @company.workflows.where(template: template).order(created_at: :desc)

    @workflows_sort = sort_column(@workflows)
    params[:direction] == "desc" ? @workflows_sort.reverse! : @workflows_sort
    @workflows = Kaminari.paginate_array(@workflows_sort).page(params[:page]).per(10)
  end

  def new
    @workflow = Workflow.new
    @workflow.template_data(@template)
  end

  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.user = current_user
    @workflow.company = @company
    @workflow.template = @template

    @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], xero_email: params[:workflow][:client][:xero_email], company: @company, user: current_user) unless params[:workflow][:workflowable_id].present?
    @workflow.workflowable.update(xero_email: "RON@gmail.com")


    if @workflow.save
      log_data_activity
      if params[:assign]
        redirect_to assign_symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully created.'
      else
        redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully created.'
      end
    else
      render :new
    end
  end

  def show
    if @workflow.completed?
      redirect_to symphony_archive_path(@workflow.template.slug, @workflow.identifier)
    else
      @sections = @template.sections
      @section = params[:section_id] ? @sections.find(params[:section_id]) : @workflow.current_section
      @activities = PublicActivity::Activity.where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")

      set_tasks
      set_documents
    end
  end

  def edit
  end

  def update
    @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], company: @company) unless params[:workflow][:workflowable_id].present? or @workflow.workflowable.present?

    if @workflow.update(workflow_params)
      log_data_activity
      log_workflow_activity
      if params[:assign]
        redirect_to assign_symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully edited.'
      elsif params[:document_id]
        redirect_to data_entry_symphony_workflow_path(@template.slug, @workflow.identifier, document_id: params[:document_id]), notice: 'Attributes were successfully saved.'
      else
        redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully edited.'
      end
    else
      render :edit
    end
  end

  def assign
    @sections = @template.sections
  end

  def send_reminder
    current_task = Task.find(params[:task_id])
    current_action = WorkflowAction.find(params[:action_id])
    respond_to do |format|
      if current_task.role.present?
        users = User.with_role(current_task.role.name.to_sym, @company)
        NotificationMailer.deliver_notifications(current_task, current_action, users)
        format.json { render json: "Sent out", status: :ok }
      else
        format.json { render json: "Current task has no role" }
      end
    end
  end

  def archive
    set_workflow
    generate_archive = GenerateArchive.new(@workflow).run
    # Mark workflow as completed when workflow is archive
    if generate_archive.success?
      redirect_to symphony_archive_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully archived.'
    else
      redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), alert: 'There was an error archiving this workflow. Please contact your admin with details of this error.'
    end
  end

  def stop_reminder
    action = Task.find(params[:task_id])
    action.reminders.each { |reminder| reminder.update_attributes(next_reminder: nil) }
    respond_to do |format|
      format.json { render json: "Reminder stopped", status: :ok }
      format.js   { render js: 'Turbolinks.visit(location.toString());' }
    end
  end

  def reset
    @workflow_actions = @company.workflow_actions.where(workflow_id: @workflow.id)
    @workflow.update_attribute(:completed, false)
    @workflow_actions.update_all(completed: false, completed_user_id: nil)
    @workflow.create_activity key: 'workflow.reset', owner: @user
    redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully reset.'
  end

  def activities
    set_workflow
    @get_activities = PublicActivity::Activity.where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")
    @activities = Kaminari.paginate_array(@get_activities).page(params[:page]).per(10)
  end

  def data_entry
    set_documents
    unless @documents.empty?
      @document = @documents.where(id: params[:document_id]).exists? ? @documents.find(params[:document_id]) : @documents.last
      @previous_document = @documents.where('id < ?', @document.id).first
      @next_document = @documents.where('id > ?', @document.id).last
    end

    @xero = Xero.new(session[:xero_auth])
    @accounts = @xero.get_accounts
  end

  def xero_create_invoice_payable
    begin
      xero_error = false
      @xero = Xero.new(session[:xero_auth])
      invoice = @xero.create_invoice_payable(@workflow.workflowable.xero_contact_id, params[:date], params[:due_date], @workflow.identifier, params[:item_code], params[:description], params[:quantity], params[:price], params[:account])
      @workflow.documents.each do |document|
        invoice.attach_data(document.filename, open(URI('http:' + document.file_url)).read, MiniMime.lookup_by_filename(document.file_url).content_type)
      end
    rescue ArgumentError => e
      xero_error = true
      message = 'There was an error creating Xero invoice: ' + e.message + '. Please ensure you have filled in all the required data attributes.'
    rescue Xeroizer::ApiException, URI::InvalidURIError => e
      xero_error = true
      if invoice.present? and invoice.invoice_id.present?
        message = 'Xero invoice was successfully created but there was an error uploading attachements: ' + e.message + '. Please upload the attachment manually in Xero.'
      else
        message = 'There was an error creating Xero invoice: ' + e.message + '. Please ensure you have filled in all the required data attributes.'
      end
    end

    if xero_error == false
      redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Xero invoice was successfully created.'
    else
      Rails.logger.error("Xero Export Error: #{message}")
      redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), alert: message
    end
  end

  def send_email_to_xero
    @workflow = Workflow.find_by(identifier: params[:workflow_identifier])

    @workflow.documents.each do |workflow_docs|
        WorkflowMailer.welcome_email(@workflow, workflow_docs).deliver
    end
    flash[:notice] = "#{@workflow.documents.count} email/s have been generated for Xero. Please check Xero in a few minutes."
    redirect_to symphony_workflow_path(@template.slug, @workflow.identifier)
  end

  private

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end

  def set_company_and_roles
    @user = current_user
    @company = @user.company
    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

  def set_workflow
    @workflows = @company.workflows
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])
    @documents = @company.documents.order(created_at: :desc)
    @document_templates = DocumentTemplate.where(template: @workflow.template)
  end

  def set_clients
    @clients = Client.where(company: @company)
  end

  def set_attributes_metadata
    params[:workflow][:data_attributes]&.each do |key, value|
      if value[:_create] == '1' or value[:_update] == '1' or value[:_destroy] == '1'
        value[:user_id] = @user.id
        value[:updated_at] = Time.current
      end
    end
  end

  def log_data_activity
    params[:workflow][:data_attributes]&.each do |key, value|
      next if value[:name].empty? and value[:value].empty?
      if value[:_create] == '1'
        @workflow.create_activity key: 'workflow.create_attribute', owner: User.find_by(id: value[:user_id]), params: { attribute: {name: value[:name], value: value[:value]} }
      elsif value[:_update] == '1'
        @workflow.create_activity key: 'workflow.update_attribute', owner: User.find_by(id: value[:user_id]), params: { attribute: {name: value[:name], value: value[:value]} }
      elsif value[:_destroy] == '1'
        @workflow.create_activity key: 'workflow.destroy_attribute', owner: User.find_by(id: value[:user_id]), params: { attribute: {name: value[:name], value: value[:value]} }
      end
    end
  end

  def log_workflow_activity
    @workflow.previous_changes.each do |key, value|
      next if key == 'updated_at' or key == 'data'
      if key == "deadline"
        @workflow.create_activity key: 'workflow.update', owner: User.find_by(id: current_user.id), params: { attribute: {name: key, value: value.last.strftime('%F') } }
      elsif key == "workflowable_id"
        @workflow.create_activity key: 'workflow.update', owner: User.find_by(id: current_user.id), params: { attribute: {name: @workflow.workflowable_type.downcase, value: @workflow.workflowable.name, workflowable_id: value.last } }
      else
        @workflow.create_activity key: 'workflow.update', owner: User.find_by(id: current_user.id), params: { attribute: {name: key, value: value.last} }
      end
    end
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed, :deadline, :identifier, :workflowable_id, :workflowable_type, :remarks,workflowable_attributes: [:id, :name, :identifier, :user_id, :company_id, :xero_contact_id, :xero_email], data_attributes: [:name, :value, :user_id, :updated_at, :_create, :_update, :_destroy])
  end

  def set_documents
    @documents = @company.documents.where(workflow_id: @workflow.id).order(created_at: :desc)
  end

  def sort_column(array)
    array.sort_by{
      |item| if params[:sort] == "template" then item.template.title.upcase
      elsif params[:sort] == "remarks" then item.remarks ? item.remarks.upcase : ""
      elsif params[:sort] == "deadline" then item.deadline ? item.deadline : Time.at(0)
      elsif params[:sort] == "workflowable" then item.workflowable ? item.workflowable&.name.upcase : ""
      elsif params[:sort] == "completed" then item.completed ? 'Completed' : item.current_section&.display_name
      elsif params[:sort] == "identifier" then item.identifier ? item.identifier.upcase : ""
      end
    }
  end

  def xero_login
    redirect_to user_xero_omniauth_authorize_path
  end
end