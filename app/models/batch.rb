class Batch < ApplicationRecord
  belongs_to :company
  belongs_to :template
  belongs_to :user
  has_many :workflows, dependent: :destroy

  # replacement for .first/.last because we use uuids
  def self.first
    order("batches.created_at").first
  end

  def self.last
    order("batches.created_at DESC").first
  end

  def action_completed_progress
    # Check for case where total_action is 0 to prevent NaN error
    total_action == 0 ? 0 : ((get_completed_actions.count.to_f / total_action) * 100).round(0) if total_action.present?
  end

  def average_time_taken_per_task
    #display time in seconds, divided by the total number of action
    ((self.updated_at - self.created_at) / total_action).round(2)
  end

  #Since each template's workflows have the same workflow_actions, can get the total number of actions by multiplying the number of workflows in batch with the workflow_actions of ANY one workflow
  def total_action
    self.workflows.present? ? (self.workflows.count * self.workflows[0].workflow_actions.count) : 0
  end

  #get all the completed workflow action in an array
  def get_completed_actions
    self.workflows.includes(:workflow_actions).where(workflow_actions: {completed: true})
  end

  def name
    self.created_at.strftime('%y%m%d-%H%M')
  end

  def next_task(workflow, workflow_action)
    workflow = self.workflows.where('created_at > ?', workflow.created_at).order(created_at: :asc).first    
    show_workflow_action_by_workflow(workflow, workflow_action)
  end

  def previous_task(workflow, workflow_action)
    workflow = self.workflows.where('created_at < ?', workflow.created_at).order(created_at: :asc).last
    show_workflow_action_by_workflow(workflow, workflow_action)    
  end

  private

  def show_workflow_action_by_workflow(workflow, workflow_action)
    if workflow.present?
      workflow.workflow_actions.find_by(task_id: workflow_action.task_id)
    end
  end
end
