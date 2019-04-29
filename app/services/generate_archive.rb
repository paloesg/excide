class GenerateArchive

  def initialize(workflow)
    @workflow = workflow
  end

  def run
    begin
      @workflow.transaction do
        @workflow.update_columns(completed: true, archive: generate_archive)
        send_email_summary
        delete_reminders
        delete_workflow_actions
        delete_activities
      end
      OpenStruct.new(success?: true, workflow: @workflow)
    rescue => e
      OpenStruct.new(success?: false, workflow: @workflow, message: e.message)
    end
  end

  private

  def generate_archive
    { workflow: { user: @workflow.user.full_name, remarks: @workflow.remarks, deadline: @workflow.deadline, company: @workflow.company.name, activity_log: activity_log.to_a, archived_at: Time.current, data: @workflow.data, client_type: @workflow.workflowable_type, client_name: @workflow.workflowable&.name, client_identifier: @workflow.workflowable&.identifier, client_company: @workflow.workflowable&.company&.name, template: generate_archive_template } }
  end

  def generate_archive_template
    { title: @workflow.template.title, business_model: @workflow.template.business_model, slug: @workflow.template.slug, sections: generate_archive_sections }
  end

  def generate_archive_sections
    archive_sections = []
    sections = @workflow.template.sections
    sections.each do |section|
      archive_section = { unique_name: section.unique_name, display_name: section.display_name, position: section.position, tasks: generate_archive_tasks(section) }
      archive_sections << archive_section
    end
    archive_sections
  end

  def generate_archive_tasks(section)
    archive_tasks = []
    workflow_actions = WorkflowAction.where(workflow: @workflow).joins(:task).where(tasks: { section_id: section.id })
    workflow_actions.each do |action|
      archive_task = { instructions: action.task.instructions, position: action.task.position, image_url: action.task.image_url, link_url: action.task.link_url, role_name: action.task.role&.display_name, task_type: action.task.task_type, workflow_actions: { completed: action.completed, deadline: action.deadline, company: action.company&.name, assigned_user: action.assigned_user&.full_name, completed_user: action.completed_user&.full_name, remarks: action.remarks } }
      archive_tasks << archive_task
    end
    archive_tasks
  end

  def send_email_summary
    WorkflowMailer.email_summary(@workflow, @workflow.user, @workflow.company).deliver_now
  end

  def activity_log
    PublicActivity::Activity.where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")
  end

  def delete_reminders
    @workflow.workflow_actions.each do |action|
      action.reminders.destroy_all if action.reminders
    end
  end

  def delete_workflow_actions
    @workflow.workflow_actions.destroy_all
  end

  def delete_activities
    activity_log.destroy_all
  end
end