class Motif::WorkflowsController < ApplicationController
  layout 'motif/application'
  include Motif::WorkflowsHelper
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_workflow, only: [:show, :update, :destroy]
  before_action :set_workflow_by_id, only: [:next_workflow, :prev_workflow, :toggle, :notify_franchisor]

  def index
    # For INDEX workflow page
    @template_type = params[:template_type]
    # Select templates in that company and with the right template_type. params[:template_type] is passed through url params in the sidebar
    @templates = Template.includes(:company, :workflows).where(company_id: @company.id, template_type: @template_type).where(workflows: {id: nil})
    # Get workflows based on condition in workflow helper method
    @workflows = get_workflows(current_user, @template_type)
    @outlets = Outlet.includes(:company).where(companies: { id: @company.id })
    @workflow = Workflow.new
  end

  def show
    @documents = policy_scope(Document).order(created_at: :desc)
    # Find the next workflow of the current workflow
    @next_wf = @workflow.template.workflows.where('created_at > ?', @workflow.created_at).order(created_at: :asc).first
    # Find the previous workflow of the current workflow
    @prev_wf = @workflow.template.workflows.where('created_at < ?', @workflow.created_at).order(created_at: :asc).last
  end

  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.user = @user
    @workflow.company = @company
    respond_to do |format|
      if @workflow.save
        # Set next workflow date for site audit and royalty collection templates
        @workflow.template.set_next_workflow_date(@workflow)
        format.html { redirect_to motif_workflows_path(template_type: @workflow.template.template_type), notice: 'Workflow was successfully created.' }
        format.json { render :show, status: :created, location: @workflow }
      else
        format.html { render :new }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    @wfa = @workflow.workflow_actions.find(params[:workflow_action_id])
    respond_to do |format|
      if @wfa.save
        format.html { redirect_to motif_outlet_workflow_path(outlet_id: @wfa.workflow.outlet.id, id: @wfa.workflow.id) , notice: 'Workflow was successfully created.' }
        format.json { render :show, status: :created, location: @wfa }
      else
        format.html { render :new }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    @action = Task.find_by_id(params[:task_id]).get_workflow_action(@company.id, params[:workflow_id])
    authorize @workflow
    respond_to do |format|
      if @action.update_attributes(completed: !@action.completed, completed_user_id: current_user.id, current_action: false, notify_status: false)
        format.json { render json: @action.completed, status: :ok }
        flash[:notice] = "You have successfully completed all outstanding items for your current task." if @action.all_actions_task_group_completed?
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  def notify_franchisor
    @wfa = WorkflowAction.find_by(id: params[:wfa_id])
    link_address = "#{ENV['ASSET_HOST'] + motif_outlet_workflow_path(outlet_id: @wfa.workflow.outlet.id, id: @workflow.id)}"
    # find franchisor(s) from that company
    @franchisors = @workflow.company.find_franchisors
    @franchisors.each do |franchisor|
      NotificationMailer.motif_notify_franchisor(franchisor, current_user, @wfa, link_address).deliver_later
    end
    respond_to do |format|
      # Update workflow_actions notify_status to true, indicating franchisor has been notified
      if @wfa.update(notify_status: true)
        format.html { redirect_to motif_outlet_workflow_path(outlet_id: @workflow.outlet.id, id: @workflow.id), notice: "You've notified the franchisor. Please wait for the franchisor to reply." }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
    end
  end

  def destroy
    if @workflow.destroy
      respond_to do |format|
        format.html { redirect_to motif_outlet_assigned_tasks_path(outlet_id: @workflow.outlet.id) }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Routine was successfully deleted.'
    end
  end

  def next_workflow
    next_wf = @workflow.template.workflows.where('created_at > ?', @workflow.created_at).order(created_at: :asc).first
    # Redirect to next workflow if next_wf is present
    redirect_to motif_outlet_workflow_path(outlet_id: next_wf.outlet, id: next_wf.id) if next_wf.present?
  end

  def prev_workflow
    prev_wf = @workflow.template.workflows.where('created_at < ?', @workflow.created_at).order(created_at: :asc).last
    redirect_to motif_outlet_workflow_path(outlet_id: prev_wf.outlet, id: prev_wf.id) if prev_wf.present?
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_workflow
    @workflow = Workflow.find(params[:id])
  end

  def set_workflow_by_id
    @workflow = Workflow.find(params[:workflow_id])
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :outlet_id, :completed, :deadline, :workflowable_id, :workflowable_type, :remarks, workflowable_attributes: [:id, :name, :identifier, :user_id, :company_id, :xero_email], data_attributes: [:name, :value, :user_id, :updated_at, :_create, :_update, :_destroy])
  end
end
