class UpdateWorkflowAction
  def initialize(template)
    @template = template
  end

  def run
    begin
      update_workflow_actions
      OpenStruct.new(success?: true)
    rescue => e
      OpenStruct.new(success?: false, message: e.message)
    end
  end

  private
  def update_workflow_actions
    @template.tasks.each do |task|
      # If there's assigned_user, it will store the ID, else it will be nil
      task.workflow_actions.map { |wfa| 
        wfa.assigned_user_id = task.user_id
        wfa.save
      }
    end
  end
end
