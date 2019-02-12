class WorkflowAction < ApplicationRecord
  include PublicActivity::Model
  tracked except: [:create, :destroy],
          owner: ->(controller, _model) { controller&.current_user },
          recipient: ->(_controller, model) { model&.workflow },
          params: {
            instructions: ->(_controller, model) { model&.task&.instructions },
            completed: ->(_controller, model) { model&.completed? }
          }

  after_save :clear_reminders, if: :saved_change_to_completed?
  after_save :trigger_next_task, if: :saved_change_to_completed?
  after_save :send_notification, if: :saved_change_to_completed?

  belongs_to :task
  belongs_to :company
  belongs_to :workflow

  belongs_to :assigned_user, class_name: 'User'
  belongs_to :completed_user, class_name: 'User'

  has_many :reminders, dependent: :destroy

  def set_deadline_and_notify(next_task)
    next_action = next_task.get_workflow_action(self.company, self.workflow.identifier)
    next_action.update_columns(deadline: check_week_day(Date.current + next_task.days_to_complete)) unless next_task.days_to_complete.nil?

    # Create new reminder based on deadline of action and repeat every 2 days
    create_reminder(next_task, next_action) if (next_task.set_reminder && next_action.deadline.present?)

    # Trigger email notification for next task if role present
    if next_task.role.present?
      users = User.with_role(next_task.role.name.to_sym, self.company)
      #false indicates (on deliver_notifications param) that it is not called from the send_reminder button
      NotificationMailer.deliver_notifications(workflow.workflow_type, next_task, next_action, users, false)
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

  private

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
      next_reminder: check_week_day(action.deadline),
      repeat: true,
      freq_value: 2,
      freq_unit: "days",
      company_id: action.company_id,
      task_id: task.id,
      workflow_action_id: action.id,
      title: '[Reminder] ' + task.section.template.title + ' - ' + action.workflow.identifier,
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

  def check_week_day(day)
    day.on_weekday? ? day : day.next_weekday
  end
end