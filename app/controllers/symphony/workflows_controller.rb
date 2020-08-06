class Symphony::WorkflowsController < ApplicationController
  include Adapter

  rescue_from Xeroizer::InvoiceNotFoundError, with: :xero_error_invoice_not_found

  before_action :authenticate_user!
  before_action :set_company_and_roles
  before_action :set_template, except: [:toggle_all]
  before_action :set_clients, only: [:new, :create, :edit, :update]
  before_action :set_workflow, only: [:show, :edit, :update, :destroy, :assign, :archive, :reset, :data_entry, :xero_create_invoice, :send_email_to_xero]
  before_action :set_attributes_metadata, only: [:update]
  before_action :set_twilio_account, only:[:send_reminder]

  after_action :verify_authorized, except: [:index, :send_reminder, :stop_reminder]
  after_action :verify_policy_scoped, only: :index

  def index
    @workflows = @template.workflows.select{|wf| params[:year].present? ? wf.created_at.year.to_s == params[:year] : wf.deadline.year == Time.current.year}.sort_by{|wf| wf.created_at}
  end

  def new
    authorize @template, :check_template?
    @workflow = Workflow.new
    authorize @workflow
    @workflow.template_data(@template)
  end

  def create
    @workflow = Workflow.new
    @workflow.user = current_user
    @workflow.completed = false
    @workflow.company = @company
    @workflow.template = @template
    @workflow.workflow_action_id = params[:action_id] if params[:action_id]
    authorize @workflow

    if @workflow.save
      # log_data_activity
      redirect_to symphony_workflow_path(@template.slug, @workflow.id), notice: 'Workflow was successfully created.'
    else
      render :new
    end
  end

  def show
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
    authorize @workflow
    @invoice = Invoice.find_by(workflow_id: @workflow.id)
    @surveys = Survey.all.where(workflow_id: @workflow.id)
    @templates = policy_scope(Template).assigned_templates(current_user)
    @sections = @template.sections
    @get_activities = PublicActivity::Activity.includes(:owner).where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")
    @activities = Kaminari.paginate_array(@get_activities).page(params[:page]).per(5)
    @workflows = @template.workflows.select{|wf| params[:year].present? ? wf.created_at.year.to_s == params[:year] : wf.created_at.year == @workflow.created_at.year}.sort_by{|wf| wf.created_at}

    if @workflow.completed?
      @section = params[:section_id] ? @sections.find(params[:section_id]) : @sections.last
    else
      @section = params[:section_id] ? @sections.find(params[:section_id]) : @workflow.current_section
    end

    set_tasks
    set_documents
  end

  def edit
    authorize @workflow
  end

  def update
    authorize @workflow
    if @workflow.update(workflow_params)
      #if workflow.workflowable is present, don't need to create client. If no workflowable params is posted(such as in the case of data-entry), no client is created too.
      @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], company: @company, user: current_user) unless @workflow.workflowable.present? or params[:workflow][:workflowable].present? or params[:workflow][:client].nil?
      if @workflow.save
        log_data_activity
        log_workflow_activity
        if params[:enter_data_type] && params[:enter_data_type] == 'batch_enter_data'
          workflow_action = WorkflowAction.find(params[:workflow_action])
          if workflow_action.update_attributes(completed: !workflow_action.completed, completed_user_id: current_user.id)
            redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id), notice: "#{@action.task.instructions} done!"
          end
        elsif params[:assign]
          redirect_to assign_symphony_workflow_path(@template.slug, @workflow.id), notice: 'Workflow was successfully edited.'
        elsif params[:document_id]
          redirect_to data_entry_symphony_workflow_path(@template.slug, @workflow.id, document_id: params[:document_id]), notice: 'Attributes were successfully saved.'
        else
          redirect_to symphony_workflow_path(@template.slug, @workflow.id), notice: 'Workflow was successfully edited.'
        end
      else
        render :edit
      end
    else
      render :edit
    end
  end

  def destroy
    authorize @workflow
    @batch = @workflow.batch
    if @workflow.destroy
      if @batch.present?
        redirect_to symphony_batch_path(@template.slug, @batch.id)
        respond_to do |format|
          format.js  { flash[:notice] = 'Workflow was successfully deleted.' }
        end
      end
    end
  end

  def workflow_action_complete
    @workflow = policy_scope(Workflow).find(params[:workflow_id])
    authorize @workflow

    workflow_action = WorkflowAction.find(params[:action_id])
    respond_to do |format|
      if workflow_action.update_attributes(completed: true, completed_user_id: current_user.id)
        if @workflow.batch
          # Display different flash message when all actions task group is completed
          if workflow_action.all_actions_task_group_completed?
            flash[:notice] = "You have successfully completed all outstanding items for your current task."
          else
            flash[:notice] = "#{workflow_action.task.instructions} done!"
          end
          format.html {redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id)}
        else
          format.html {redirect_to symphony_workflow_path(@template.slug, @workflow.id), notice: "#{workflow_action.task.instructions} done!"}
        end
      else
        format.json { render json: workflow_action.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    @action = Task.find_by_id(params[:task_id]).get_workflow_action(@company.id, params[:workflow_id])
    @workflow = policy_scope(Workflow).find(params[:workflow_id])
    authorize @workflow
    #manually saving updated_at of the batch to current time
    @workflow.batch.update(updated_at: Time.current) if @workflow.batch.present?
    respond_to do |format|
      if @action.update_attributes(completed: !@action.completed, completed_user_id: current_user.id)
        format.json { render json: @action.completed, status: :ok }
        flash[:notice] = "You have successfully completed all outstanding items for your current task." if @action.all_actions_task_group_completed?
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_all
    @actions = WorkflowAction.where(id: params[:workflow_action_ids])
    @workflow = @actions.last.workflow
    authorize @workflow
    #manually saving updated_at of the batch to current time
    @workflow.batch.update(updated_at: Time.current) if @workflow.batch.present?
    respond_to do |format|
      if @actions.update_all(completed: true, completed_user_id: current_user.id)
        format.json { render json: true, status: :ok }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.json { render json: @actions.errors, status: :unprocessable_entity }
      end
    end
  end

  def assign
    authorize @workflow
    @sections = @template.sections.includes(tasks: :role)
  end

  def send_reminder
    current_task = Task.find(params[:task_id])
    current_action = WorkflowAction.find(params[:action_id])
    respond_to do |format|
      if current_task.role.present?
        users = User.with_role(current_task.role.name.to_sym, @company)
        current_action.notify :users, key: "workflow_action.task_notify", parameters: { printable_notifiable_name: "#{current_action.task.instructions}", workflow_action_id: current_action.id }, send_later: false
        users.each do |user|
          NotificationMailer.task_notification(current_task, current_action, user).deliver_later if user.settings[0]&.reminder_email == 'true'
          # Only send slack, whatsapp and sms notification when company is PRO
          if @company.pro?
            # Check if slack is connected using company.slack_access_response.present?
            SlackService.new(user).task_notification(current_task, current_action, user).deliver if (user.settings[0]&.reminder_slack == 'true' && user.company.slack_access_response.present?)
            to_number = '+65' + user.contact_number
            message_body = current_task.instructions
            message_head = current_action.workflow.template.title
            # message for sms
            message = @client.api.account.messages.create( from: @from_number, to: to_number, body: "#{message_head} Please be reminded to perform this task: #{message_body}" ) if user.settings[0]&.reminder_sms == 'true'
            # message for whatsapp
            message_whatsapp = @client.messages.create( from: 'whatsapp:'+@from_number, to: 'whatsapp:'+to_number, body: "#{message_head} Please be reminded to perform this task: #{message_body}" ) if user.settings[0]&.reminder_whatsapp == 'true'
          end
        end
        format.json { render json: "Sent out", status: :ok }
      else
        format.json { render json: "Current task has no role" }
      end
    end
  end

  def archive
    authorize @workflow
    generate_archive = GenerateArchive.new(@workflow).run
    # Mark workflow as completed when workflow is archived
    if generate_archive.success?
      redirect_to symphony_archive_path(@template.slug, @workflow.id), notice: 'Workflow was successfully archived.'
    else
      redirect_to symphony_workflow_path(@template.slug, @workflow.id), alert: "There was an error archiving this workflow. Please contact your admin with details of this error: #{generate_archive.message}."
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
    authorize @workflow
    @workflow_actions = @company.workflow_actions.where(workflow_id: @workflow.id)
    @workflow.update_attribute(:completed, false)
    @workflow_actions.update_all(completed: false, completed_user_id: nil)
    @workflow.create_activity key: 'workflow.reset', owner: @user
    redirect_to symphony_workflow_path(@template.slug, @workflow.id), notice: 'Workflow was successfully reset.'
  end

  def data_entry
    authorize @workflow
    set_documents
    unless @documents.empty?
      @document = @documents.where(id: params[:document_id]).exists? ? @documents.find(params[:document_id]) : @documents.last
      @previous_document = @documents.where('id < ?', @document.id).first
      @next_document = @documents.where('id > ?', @document.id).last
    end
  end

  def xero_create_invoice
    @xero = Xero.new(@workflow.company)
    authorize @workflow
    xero_invoice = @xero.create_invoice(@workflow.invoice.xero_contact_id, @workflow.invoice.invoice_date, @workflow.invoice.due_date, @workflow.invoice.line_items, @workflow.invoice.line_amount_type, @workflow.invoice.invoice_reference, @workflow.invoice.currency, @workflow.invoice.invoice_type)
    @workflow.invoice.xero_invoice_id = xero_invoice.id
    @workflow.documents.each do |document|
      if document.raw_file.attached?
        # Remove whitespaces for filename and certain special characters
        xero_invoice.attach_data(document.raw_file.filename.to_s.gsub(/\s+/, "").gsub(/[!@%&$"]/,''), Net::HTTP.get(URI.parse(document.raw_file.service_url)), document.raw_file.blob.content_type)
      else
        xero_invoice.attach_data(document.filename, open(URI('http:' + document.file_url)).read, MiniMime.lookup_by_filename(document.file_url).content_type)
      end
    end
    @workflow.invoice.save
    #this is to send invoice to xero 'awaiting approval'
    if params[:approved].present?
      xero_invoice.status = "SUBMITTED"
      @workflow.invoice.verified
    #this is to send invoice to xero 'awaiting payment', default status will be 'draft'
    elsif params[:payment].present?
      xero_invoice.status = "AUTHORISED"
      @workflow.invoice.approved
    end
    @workflow.invoice.save
    xero_invoice.save

    respond_to do |format|
      if @workflow.invoice.errors.empty?
        workflow_action = @workflow.workflow_actions.find(params[:workflow_action_id])
        workflow_action.update_attributes(completed: true, completed_user_id: current_user.id) if params[:workflow_action_id].present?

        if xero_invoice.errors.any?
          flash[:alert] = "Xero invoice was not sent to Xero!"
        elsif xero_invoice.total == @workflow.invoice.total
          flash[:notice] = "Xero invoice has been created successfully and the invoice totals match."
        else
          #set invoice to status: xero_total_mismatch if symphony invoice total doesn't tally with xero's total
          @workflow.invoice.mismatch
          @workflow.invoice.save
          flash[:alert] = "Xero invoice has been created successfully but the invoice totals do not match. Please check rounding and then update on Xero!"
        end

        if @workflow.batch
          incomplete_workflows = @workflow.batch.workflows.includes([{workflow_actions: :task}, :invoice]).where(workflow_actions: {tasks: {id: workflow_action.task_id}, completed: false}).where.not(invoices: {id: nil}).order(created_at: :asc)

          if incomplete_workflows.count > 0 and !@workflow.invoice.xero_total_mismatch?
            next_wf = incomplete_workflows.where('workflows.created_at > ?', @workflow.created_at).first
            if next_wf.blank?
              next_wf = incomplete_workflows.where('workflows.created_at < ?', @workflow.created_at).first
            end
            if next_wf.present?
              next_wf_action = next_wf.workflow_actions.where(completed: false).first
              format.html{redirect_to edit_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, id: next_wf.invoice.id, workflow_action_id: next_wf_action.id)}
            end
          elsif incomplete_workflows.count > 0 and @workflow.invoice.xero_total_mismatch?
            #redirect back to current invoice edit page
            format.html{ redirect_to edit_symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @workflow.invoice.id, workflow_action_id: @workflow.get_workflow_action(workflow_action.task_id).id)}
          else
            #if this is the last task but the xero total mismatched, redirect back to it's invoice EDIT page instead of batch INDEX
            if !@workflow.invoice.xero_total_mismatch?
              format.html{redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id)}
            else
              format.html{ redirect_to edit_symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @workflow.invoice.id, workflow_action_id: @workflow.get_workflow_action(workflow_action.task_id).id)}
            end
          end
        else
          format.html{ redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.id)}
        end
      else
        flash[:alert] = "Invoice is not save in Symphony successfully!"
        if @workflow.batch
          format.html{redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id)}
        else
          format.html{ redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.id) }
        end
      end
    end
  end

  def send_email_to_xero
    authorize @workflow
    @workflow.documents.each do |workflow_docs|
        WorkflowMailer.send_invoice_email(@workflow, workflow_docs).deliver_later
    end
    flash[:notice] = "#{@workflow.documents.count} email/s have been generated for Xero. Please check Xero in a few minutes."
    redirect_to symphony_workflow_path(@template.slug, @workflow.id)
  end

  private

  def set_template
    @template = policy_scope(Template).find(params[:workflow_name])
  end

  def set_tasks
    @next_section = @workflow.next_section
    @tasks = @section&.tasks.includes(:role, :user)
    @current_task = @workflow.current_task
  end

  def set_company_and_roles
    @user = current_user
    @company = @user.company
    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

  def set_workflow
    @workflow = policy_scope(Workflow).find(params[:workflow_id])
    @documents = @company.documents.order(created_at: :desc)
    @document_templates = DocumentTemplate.where(template: @workflow.template)
  end

  def set_clients
    @clients = Client.where(company: @company)
  end

  def set_attributes_metadata
    params[:workflow][:data_attributes]&.each do |_key, value|
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

  def xero_error_invoice_not_found(e)
    message = 'Xero returned an API error - ' + e.to_s + '. Please check the document that was uploaded or contact admin.'
    Rails.logger.error("Xero API error: #{message}")
    redirect_to session[:previous_url], alert: message
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed, :deadline, :workflowable_id, :workflowable_type, :remarks, workflowable_attributes: [:id, :name, :identifier, :user_id, :company_id, :xero_email], data_attributes: [:name, :value, :user_id, :updated_at, :_create, :_update, :_destroy])
  end

  def set_documents
    @documents = @company.documents.where(workflow_id: @workflow.id).order(created_at: :desc)
  end

  def sort_column(array)
    array.sort_by{
      |item| if params[:sort] == "remarks" then item.remarks ? item.remarks.upcase : ""
      elsif params[:sort] == "deadline" then item.deadline ? item.deadline : Time.at(0)
      elsif params[:sort] == "workflowable" then item.workflowable ? item.workflowable&.name.upcase : ""
      elsif params[:sort] == "completed" then item.completed ? 'Completed' : item.current_section&.section_name
      end
    }
  end

  def set_twilio_account
    @from_number = ENV['TWILIO_NUMBER']
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new account_sid, auth_token
  end
end
