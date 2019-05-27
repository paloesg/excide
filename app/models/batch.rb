class Batch < ApplicationRecord
  belongs_to :company
  belongs_to :template
  has_many :workflows, dependent: :destroy

  # replacement for .first/.last because we use uuids
  def self.first
    order("batches.created_at").first
  end
    
  def self.last
    order("batches.created_at DESC").first
  end

  #this method gets an array of names of roles in all the workflows of Batch. Using this, we can compare the roles with current_user's role to reveal their batches in the INDEX page
  def get_relevant_roles 
    self.workflows.map{|wf| wf.get_roles.map(&:name).map(&:downcase)}.flatten.compact.uniq
  end

  def action_completed_progress
    ( (get_completed_actions.count.to_f / total_action) * 100).round(2)
  end

  def average_time_taken_per_task
    ((Date.current - self.created_at.to_date).to_f / total_action)
  end

  #Since each template's workflows have the same workflow_actions, can get the total number of actions by multiplying the number of workflows in batch with the workflow_actions of ANY one workflow
  def total_action
    self.workflows.count * self.workflows[0].workflow_actions.count
  end
  #get all the completed workflow action in an array
  def get_completed_actions
    self.workflows.map{|wf| wf.workflow_actions}.flatten.compact.select{|action| action.completed?}
  end
end
