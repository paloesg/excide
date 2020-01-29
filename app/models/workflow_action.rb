class WorkflowAction < ApplicationRecord
  include PublicActivity::Model
  tracked except: [:create, :destroy],
          owner: ->(controller, _model) { controller&.current_user },
          recipient: ->(_controller, model) { model&.workflow },
          params: {
            instructions: ->(_controller, model) { model&.task&.instructions },
            completed: ->(_controller, model) { model&.completed? }
          }

  after_save :clear_reminders, if: :ordered_workflow_task_completed?
  after_save :trigger_next_task, if: :ordered_workflow_task_completed?
  after_save :workflow_completed , if: :check_all_actions_completed?
  after_save :update_batch_progress

  belongs_to :task
  belongs_to :company
  belongs_to :workflow

  belongs_to :assigned_user, class_name: 'User'
  belongs_to :completed_user, class_name: 'User'

  has_many :reminders, dependent: :destroy
  has_many :documents, dependent: :destroy

  has_one :sub_workflow, class_name: 'Workflow'
  has_one :invoice

  def set_deadline_and_notify(next_task)
    next_action = next_task.get_workflow_action(self.company, self.workflow.id)
    next_action.update(deadline: next_task.days_to_complete.business_days.after(Date.current)) unless next_task.days_to_complete.nil?

    # Create new reminder based on deadline of action and repeat every 2 days
    create_reminder(next_task, next_action) if (next_task.set_reminder && next_action.deadline.present?)

    if (next_task.role.present? and self.workflow.batch.nil?) or (next_task.role.present? and self.workflow.batch.present? and all_actions_task_group_completed?)
      users = User.with_role(next_task.role.name.to_sym, self.company)
      # Trigger email notification for next task if role present
      users.each do |user|
        NotificationMailer.task_notification(next_task, next_action, user).deliver_later if user.settings[0]&.task_email == 'true'
      end
    end
  end

  def unordered_workflow_email_notification
    workflow_tasks = self.workflow.template.sections.map{|sect| sect.tasks }.flatten.compact
    task_users = workflow_tasks.map{|task| task.role.users}.flatten.compact.uniq
    #loop through all the users that have a role in that workflow
    task_users.each do |user|
      NotificationMailer.unordered_workflow_notification(user, workflow_tasks, self).deliver_later if user.settings[0]&.task_email == 'true'
    end
  end

  # Get workflow actions that are assigned to the user.
  def self.assigned_actions(user)
    where(assigned_user: user)
  end

  # Get workflow actions where tasks are assigned to the roles.
  def self.role_actions(roles)
    joins(:task).where(tasks: {role_id: roles})
  end

  # Union of workflow actions that are assigned to user and workflow actions where tasks are assigned to user role.
  # TODO: Refactor to use ActiveRecord .or after upgrading to Rails 5
  def self.all_user_actions(user)
    WorkflowAction.from("(#{assigned_actions(user).to_sql} UNION #{role_actions(user.roles).to_sql}) AS workflow_actions")
  end

  def workflow_completed
    self.workflow.update_column('completed', true)
    WorkflowMailer.email_summary(self.workflow, self.workflow.user,self.workflow.company).deliver_later unless self.workflow.batch.present?
    batch_completed
  end

  def batch_completed
    workflows = self.workflow.batch.workflows.where(completed: false)
    if workflows.blank?
      self.workflow.batch.update_column(:completed, true)
    end
  end

  # Check if workflow belongs to a batch, get all the actions by task grouping for the batch and check that all actions are completed
  def all_actions_task_group_completed?
    self.workflow.batch ? WorkflowAction.where(workflow: [self.workflow.batch.workflows.pluck(:id)], task_id: self.task.id).pluck(:completed).uniq.exclude?(false) : false
  end

  private

  def update_batch_progress
    if self.workflow.batch.present?
      self.workflow.batch.update_workflow_progress
      self.workflow.batch.update_task_progress
    end
  end

  def clear_reminders
    if self.completed
      # Find associated reminders and remove next reminder date
      self.reminders.each { |reminder| reminder.update_attributes(next_reminder: nil) } unless self.reminders.empty?
    end
  end

  def trigger_next_task
    if self.task.last? && self.completed
      # Find task in next section if last task in section
      next_section = self.task.section.get_next_section
      # Don't need to set up next task if no next section present
      if next_section.present?
        next_task = next_section.tasks.find_by(position: 1)
        set_deadline_and_notify(next_task)
      end
    elsif self.completed
      # Find next action in line and set deadline if not the last task in section
      next_task = self.task.lower_item
      set_deadline_and_notify(next_task)
    end
  end

  def create_reminder(task, action)
    reminder = Reminder.new(
      next_reminder: action.deadline,
      repeat: true,
      freq_value: 2,
      freq_unit: "days",
      company_id: action.company_id,
      task_id: task.id,
      workflow_action_id: action.id,
      title: '[Reminder] ' + task.section.template.title + ' - ' + action.workflow.id,
      content: task.instructions,
      slack: true,
      email: true
    )

    if action.assigned_user.present?
      reminder.user = action.assigned_user
      reminder.save
    else
      task.role.users.each do |user|
        user_reminder = reminder.dup
        user_reminder.user = user
        user_reminder.save
      end
    end
  end

  def send_notification
    if self.completed
      SlackService.new.send_notification(self).deliver
    end
  end

  # Callback conditional to check whether the template is of type ordered and whether the task is completed before triggering callback
  def ordered_workflow_task_completed?
    self.workflow.template.ordered? && self.completed?
  end

  #this callback checks that all actions in the workflow are completed before sending out the email summary
  def check_all_actions_completed?
    # Check length of workflow actions, to prevent workflow to be completed when creation of workflow actions (if first task completed)
    if self.workflow.workflow_actions.length == self.workflow.template.sections.joins(:tasks).length
      self.workflow.workflow_actions.all? {|action| action.completed? }
    else
      false
    end
  end
end
