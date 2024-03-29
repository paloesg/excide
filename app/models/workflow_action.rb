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
  after_save :update_batch_progress, if: :workflow_has_batch?
  after_update :update_workflow_total_time_mins

  before_destroy :untagged_all_notes

  belongs_to :task
  belongs_to :company
  belongs_to :workflow

  belongs_to :assigned_user, class_name: 'User'
  belongs_to :completed_user, class_name: 'User'

  has_many :reminders, dependent: :destroy
  has_many :documents, dependent: :destroy

  has_one :sub_workflow, class_name: 'Workflow'
  has_one :invoice

  # acts_as_notifiable configures your model as ActivityNotification::Notifiable
  # with parameters as value or custom methods defined in your model as lambda or symbol.
  # The first argument is the plural symbol name of your target model.
  # acts_as_notifiable :users,
  #   # Notification targets as :targets is a necessary option
  #   # Set to notify to author and users commented to the article, except comment owner self
  #   targets: :custom_notification_targets,
  #   # Path to move when the notification is opened by the target user
  #   # This is an optional configuration since activity_notification uses polymorphic_path as default
  #   notifiable_path: :wf_notifiable_path,
  #   dependent_notifications: :delete_all

  def custom_notification_targets(key)
    if key == 'workflow_action.task_notify' or key == 'workflow_action.unordered_workflow_notify'
      self.task.role.users.uniq
    elsif key == 'workflow_action.workflow_completed'
      # when completed all workflow actions, notify the one that created the workflow
      [self.workflow.user]
    end
  end

  def wf_notifiable_path
    symphony_workflow_path(self.workflow.template, self.workflow)
  end

  def set_deadline_and_notify(next_task)
    next_action = next_task.get_workflow_action(self.company, self.workflow.id)

    # Create new reminder based on deadline of action and repeat every 2 days
    create_reminder(next_task, next_action) if (next_task.set_reminder && next_action.deadline.present?)

    # Update next_action's current_action to true
    next_action.current_action = true
    next_action.save

    if (next_task.role.present? and self.workflow.batch.nil?) or (next_task.role.present? and self.workflow.batch.present? and all_actions_task_group_completed?)
      users = User.with_role(next_task.role.name.to_sym, self.company)
      # create task notification
      # next_action.notify :users, key: "workflow_action.task_notify", group: next_action.workflow.template, parameters: { printable_notifiable_name: "#{next_task.instructions}", workflow_action_id: next_action.id }, send_later: false
    end
  end

  def unordered_workflow_create_reminder_and_send_email
    workflow_tasks = self.workflow.template.sections.map{|sect| sect.tasks }.flatten.compact
    workflow_tasks.each do |task|
      wfa = task.get_workflow_action(self.company.id, self.workflow.id)
      create_reminder(task, wfa) if (task.set_reminder && wfa.deadline.present?)
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
    if self.workflow.update_column('completed', true)
      # Notify the user that created the workflow that it is completed
      # self.notify :users, key: "workflow_action.workflow_completed", group: self.workflow.template, parameters: { workflow_slug: self.workflow.slug }, send_later: false
      batch_completed if workflow.batch.present?
    end
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

  def get_overdue_status_colour
    # same logic as symphony homepage colour (app/views/symphony/home/index.html.slim)
    if self.deadline.to_date < Date.current
      return "text-danger"
    elsif self.deadline.to_date <= Date.tomorrow
      return "text-warning"
    elsif self.company.before_deadline_reminder_days.present? && self.deadline.to_date - self.company.before_deadline_reminder_days <= Date.current
      return "text-warning"
    else
      return "text-primary"
    end
  end

  private

  def update_workflow_total_time_mins
    self.workflow.update(total_time_mins: self.workflow.workflow_actions.sum(:time_spent_mins))
  end

  def update_batch_progress
    self.workflow.batch.update_workflow_progress
    self.workflow.batch.update_task_progress
  end

  def clear_reminders
    if self.completed
      # Find associated reminders and remove next reminder date
      self.reminders.each { |reminder| reminder.update(next_reminder: nil) } unless self.reminders.empty?
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
    reminder_date = action.deadline - (self.company.before_deadline_reminder_days&.days || 0)

    reminder = Reminder.new(
      next_reminder: (reminder_date > Date.current) ? (reminder_date) : action.deadline,
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

  def workflow_has_batch?
    self.workflow.batch.present?
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

  # Method is to unlink all notes with workflow_actions when workflow is deleted
  def untagged_all_notes
    # Loop for all the workflow actions that are going to be deleted
    Note.includes(:workflow_action).where(workflow_action_id: self.id).update(workflow_action_id: nil)
  end
end
