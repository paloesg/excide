class Symphony::WorkflowsController < WorkflowsController
  include Adapter

  before_action :set_clients, only: [:new, :create, :edit, :update]
  before_action :set_workflow, only: [:show, :edit, :update, :destroy, :assign, :section, :archive, :reset, :data_entry, :xero_create_invoice_payable]
  before_action :set_attributes_metadata, only: [:create, :update]
  before_action :set_s3_direct_post, only: [:show]

  rescue_from Xeroizer::OAuth::TokenExpired, Xeroizer::OAuth::TokenInvalid, with: :xero_login
  rescue_from Xeroizer::RecordInvalid, Xeroizer::ApiException, URI::InvalidURIError, ArgumentError, with: :xero_error

  def index
    template = Template.find(params[:workflow_name])
    @workflows = @company.workflows.includes(:template, :workflowable).where(template: template).order(created_at: :desc)

    @workflows_sort = sort_column(@workflows)
    params[:direction] == "desc" ? @workflows_sort.reverse! : @workflows_sort
    @workflows = Kaminari.paginate_array(@workflows_sort).page(params[:page]).per(10)
  end

  def new
    @workflow = Workflow.new
    @workflow.template_data(@template)
    @workflow.identifier = (Date.current.to_s + '-' + @template.title + SecureRandom.hex).parameterize.upcase
  end

  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.user = current_user
    @workflow.company = @company
    @workflow.template = @template

    if params[:workflow][:client][:name].present?
      @xero = Xero.new(session[:xero_auth])
      @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], company: @company, user: current_user)
    end

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
    @invoice = Invoice.find_by(workflow_id: @workflow.id)
    #declare 2 variables to pass into the link_to button in _xero_send_invoice.html.slim. @send_awaiting_approval's presence will cause the button to send to xero's invoice status 'AWAITING APPROVAL'. Likewise, @send_awaiting_payment will link to xero's invoice status 'AWAITING PAYMENT'
    @send_awaiting_approval = {
      approved: "approved"
    }
    @send_awaiting_payment = {
      payment: "payment"
    }
    if @workflow.completed?
      redirect_to symphony_archive_path(@workflow.template.slug, @workflow.identifier)
    else
      @sections = @template.sections
      @section = params[:section_id] ? @sections.find(params[:section_id]) : @workflow.current_section
      @activities = PublicActivity::Activity.includes(:owner).where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")

      set_tasks
      set_documents
    end
  end

  def edit
  end

  def update
    if @workflow.update(workflow_params)
      #if workflow.workflowable is present, don't need to create client. If no workflowable params is posted(such as in the case of data-entry), no client is created too.
      @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], company: @company, user: current_user) unless @workflow.workflowable.present? or params[:workflow][:workflowable].nil?
      @workflow.save
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
    generate_archive = GenerateArchive.new(@workflow).run
    # Mark workflow as completed when workflow is archived
    if generate_archive.success?
      redirect_to symphony_archive_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully archived.'
    else
      redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), alert: "There was an error archiving this workflow. Please contact your admin with details of this error: #{generate_archive.message}."
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
    @get_activities = PublicActivity::Activity.includes(:owner).where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")
    @activities = Kaminari.paginate_array(@get_activities).page(params[:page]).per(10)
  end

  def data_entry
    set_documents
    unless @documents.empty?
      @document = @documents.where(id: params[:document_id]).exists? ? @documents.find(params[:document_id]) : @documents.last
      @previous_document = @documents.where('id < ?', @document.id).first
      @next_document = @documents.where('id > ?', @document.id).last
    end
  end

  def xero_create_invoice_payable
    @xero = Xero.new(session[:xero_auth])
    if @workflow.invoice.payable?
      xero_invoice = @xero.create_invoice_payable(@workflow.invoice.xero_contact_id, @workflow.invoice.invoice_date, @workflow.invoice.due_date, @workflow.invoice.line_items, @workflow.invoice.line_amount_type, @workflow.invoice.invoice_reference, @workflow.invoice.currency)
      @workflow.invoice.xero_invoice_id = xero_invoice.id
      @workflow.documents.each do |document|
        xero_invoice.attach_data(document.filename, open(URI('http:' + document.file_url)).read, MiniMime.lookup_by_filename(document.file_url).content_type)
      end
      @invoice_payable = @xero.get_invoice(@workflow.invoice.xero_invoice_id)
      #this is to send invoice to xero 'awaiting approval'
      if params[:approved].present?
        @invoice_payable.status = "SUBMITTED"
      #this is to send invoice to xero 'awaiting payment', default status will be 'draft'
      elsif params[:payment].present?
        @invoice_payable.status = "AUTHORISED"
      end
      @invoice_payable.save
    else
      #in future if we do account receivable, must modify the adapter method create_invoice_receivable
      @invoice = @xero.create_invoice_receivable(@workflow.workflowable.xero_contact_id, @workflow.invoice.invoice_date, @workflow.invoice.due_date, "EXCIDE")
    end

    respond_to do |format|
      if @workflow.invoice.errors.empty?
        #check for any errors when sending the invoice to xero, before matching the totals
        if xero_invoice.errors.any?
          format.html{ redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.identifier), alert: "Xero invoice was not sent to Xero!" }
        elsif xero_invoice.total == @workflow.invoice.total
          format.html{ redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.identifier), notice: "Xero invoice has been created successfully and the invoice totals match." }
        else
          format.html{ redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.identifier), alert: "Xero invoice has been created successfully but the invoice totals do not match. Please check and fix the mismatch!" }
        end
      else
        format.html{ redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.identifier), alert: "Invoice is not save in Symphony successfully!" }
      end
    end
  end

  def send_email_to_xero
    @workflow = Workflow.find_by(identifier: params[:workflow_identifier])

    @workflow.documents.each do |workflow_docs|
        WorkflowMailer.send_invoice_email(@workflow, workflow_docs).deliver_later
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
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed, :deadline, :identifier, :workflowable_id, :workflowable_type, :remarks, workflowable_attributes: [:id, :name, :identifier, :user_id, :company_id, :xero_email], data_attributes: [:name, :value, :user_id, :updated_at, :_create, :_update, :_destroy])
  end

  def set_documents
    @documents = @company.documents.includes(:user).where(workflow_id: @workflow.id).order(created_at: :desc)
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

  def xero_error(e)
    message = 'Xero returned an error: ' + e.message + '. Please ensure you have filled in all the required data in the right format.'
    Rails.logger.error("Xero Error: #{message}")
    redirect_to session[:previous_url], alert: message
  end
end
