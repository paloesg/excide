class Symphony::RecurringWorkflowsController < ApplicationController
  layout "dashboard/application"
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_template
  before_action :get_recurring_workflow, only: [:edit, :update, :stop_recurring, :show]

  def index
    @recurring_workflows = RecurringWorkflow.where(company_id: @company.id)
    @templates = Template.assigned_templates(current_user)
  end

  def new
    @recurring_workflow = RecurringWorkflow.new
  end

  def create
    @recurring_workflow = RecurringWorkflow.new(recurring_workflow_params)
    @recurring_workflow.template = @template
    @recurring_workflow.company = @company
    @recurring_workflow.recurring = true
    #set the next recurring workflow date
    @recurring_workflow.next_workflow_date = Date.current + @recurring_workflow.freq_value.send(@recurring_workflow.freq_unit)
    if @recurring_workflow.save
      #creating the first workflow before recurring it through calling the service object
      @workflow = Workflow.create(user_id: current_user.id, company_id: @company.id, template_id: @recurring_workflow.template.id, recurring_workflow: @recurring_workflow, identifier: (Date.current.to_s + '-' + @recurring_workflow.template.title + '-' +SecureRandom.hex).parameterize.upcase)
      @workflow.save
      redirect_to symphony_workflow_path(@recurring_workflow.template.slug, @workflow.identifier), notice: 'Workflow was successfully created.'
    end
  end

  def edit

  end

  def update
    if @recurring_workflow.update(recurring_workflow_params)
      redirect_to symphony_workflows_recurring_path, notice: 'Recurring Workflow is successfully updated.'
    else
      edirect_to symphony_root
    end
  end

  def show
    @workflows = Kaminari.paginate_array(@recurring_workflow.workflows).page(params[:page]).per(10)
  end

  def stop_recurring
    if @recurring_workflow.update(next_workflow_date: nil)
      redirect_to symphony_workflows_recurring_path, notice: 'Recurring Workflow stopped.'
    else
      redirect_to symphony_root
    end
  end

  private

  def set_template
    @template = Template.find_by(slug: params[:recurring_workflow_name])
  end

  def get_recurring_workflow
    @recurring_workflow = @template.recurring_workflows.find_by(id: params[:id])
  end

  def recurring_workflow_params
    params.require(:recurring_workflow).permit(:recurring, :freq_value, :freq_unit, :template_id, :company_id, :next_workflow_date)
  end

  def set_company
    @company = current_user.company
  end
end
