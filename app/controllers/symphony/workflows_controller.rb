class Symphony::WorkflowsController < WorkflowsController
  def new
    @workflow = Workflow.new
  end

  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.user = @user
    @workflow.company = @company
    @workflow.template = @template

    if @workflow.save
      redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully created.'
    else
      render :new
    end
  end

  def show
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])
    @sections = @template.sections
    @current_section = @sections.joins(tasks: :company_actions).where(company_actions: {completed: false}).to_ary.shift

    set_tasks
  end

  def section
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])
    @sections = @template.sections
    @current_section = @sections.find(params[:section_id])

    set_tasks
    render :show
  end

  def approve
    @action = Task.find_by_id(params[:task_id]).get_company_action(@company, params[:workflow_identifier])

    respond_to do |format|
      if @action.update_attributes(approved_by: current_user.id)
        format.json { render json: @action.completed, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end
end