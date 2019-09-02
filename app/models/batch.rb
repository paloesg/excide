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

  #get all the completed workflow action in an array
  def get_completed_actions
    self.workflows.map{ |wf| wf.workflow_actions.where(completed: true) }.flatten.compact
  end

  def get_completed_workflows
    self.workflows.where(completed: true).count
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
    self.workflows.present? ? (self.workflows.size * self.workflows.first.workflow_actions.size) : 0
  end

  def name
    self.created_at.strftime('%y%m%d-%H%M')
  end

  def check_and_update_workflow_completed
    workflows = self.workflows.includes(:workflow_actions)
    workflows.each do |wf|
      wf.update_attribute('completed', true) if wf.workflow_actions.present? and wf.workflow_actions.all?{ |wfa| wfa.completed? }
    end
  end
end
