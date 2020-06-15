class Batch < ApplicationRecord
  include AASM

  belongs_to :company
  belongs_to :template
  belongs_to :user
  has_many :workflows, dependent: :destroy
  has_many :documents, through: :workflows
  # after_create :send_email_notification

  enum status: { processing: 0, complete: 1 }
  aasm column: :status, enum: true do
    state :processing, initial: true
    state :complete
  
    event :batch_upload do
      transitions from: :processing, to: :complete
    end
  end

  # replacement for .first/.last because we use uuids
  def self.first
    order("batches.created_at").first
  end

  def self.last
    order("batches.created_at DESC").first
  end

  #get all the completed workflow action in an array
  def get_completed_actions
    WorkflowAction.includes(:workflow).where("workflows.batch_id": self.id, completed: true)
  end

  def update_workflow_progress
    self.update_attribute(:workflow_progress, self.workflows.where(completed: true).length)
  end

  def update_task_progress
    # Check for case where total_action is 0 to prevent NaN error
    task_progress = (total_action.blank? or total_action) == 0 ? 0 : ((get_completed_actions.length.to_f / total_action) * 100).round(0)
    self.update_attribute(:task_progress, task_progress)
  end

  def average_time_taken_per_task
    #display time in seconds, divided by the total number of action
    ((self.updated_at - self.created_at) / total_action).round(2)
  end

  #Since each template's workflows have the same workflow_actions, can get the total number of actions by multiplying the number of workflows in batch with the workflow_actions of ANY one workflow
  def total_action
    self.workflows.present? ? (self.workflows.length * self.workflows.first.workflow_actions.length) : 0
  end

  def send_email_notification
    first_task = self.template.sections.first.tasks.first
    task = (first_task.task_type == "upload_file") ? first_task.lower_item : first_task
    users = User.with_role(task.role.name.to_sym, self.company)
    users.each do |user|
      NotificationMailer.first_task_notification(task, self, user).deliver_later
    end
  end

  def name
    self.created_at.strftime('%y%m%d-%H%M')
  end

  def next_workflow(current_workflow)
    next_wf = self.workflows.where('created_at > ?', current_workflow.created_at).order(created_at: :asc).first
    if next_wf.blank?
      next_wf = self.workflows.where('created_at < ?', current_workflow.created_at).order(created_at: :asc).first
    end
    return next_wf
  end

  def previous_workflow(current_workflow)
    prev_wf = self.workflows.where('created_at < ?', current_workflow.created_at).order(created_at: :asc).last
    if prev_wf.blank?
      prev_wf = self.workflows.where('created_at > ?', current_workflow.created_at).order(created_at: :asc).last
    end
    return prev_wf
  end

  def next_workflow_with_action_incomplete(workflow, workflow_action)
    self.workflows.includes(workflow_actions: :task).where(workflow_actions: {tasks: {id: workflow_action.task_id}, completed: false}).where('workflows.created_at > ?', workflow.created_at).order(created_at: :asc).first
  end

  private

  def show_workflow_action_by_workflow(workflow, workflow_action)
    if workflow.present?
      workflow.workflow_actions.find_by(task_id: workflow_action.task_id)
    end
  end
end
