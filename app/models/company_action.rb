class CompanyAction < ActiveRecord::Base
  include PublicActivity::Model
  tracked except: :create, owner: ->(controller, model) { controller && controller.current_user }

  after_save :set_deadline_and_reminders
  after_save :send_notification, if: :completed_changed?
  after_save :trigger_next_task, if: :completed_changed?

  belongs_to :task
  belongs_to :company
  belongs_to :workflow

  has_one :reminder, dependent: :destroy

  private

  def set_deadline_and_reminders
    if self.completed
      # Find associated reminders and remove next reminder date
      self.reminder.update_attributes(next_reminder: nil) if self.reminder.present?
    elsif self.task.first? && self.reminder.nil?
      # If task is first in the list, create own reminder
      self.update_columns(deadline: (Date.today + self.task.days_to_complete)) unless self.task.days_to_complete.nil?
      create_reminder(self.task, self)
    end
  end

  def trigger_next_task
    if self.task.last? && self.completed
      # Find task in next section if last task in section
      next_section = self.task.section.get_next_section
      # Don't need to set up next task if no next section present, just mark workflow as completed
      if next_section.present?
        next_task = next_section.tasks.find_by(position: 1)
        set_deadline_and_notify(next_task)
      else
        self.workflow.update_attributes(completed: true)
      end
    elsif self.completed
      # Find next action in line and set deadline if not the last task in section
      next_task = self.task.lower_item
      set_deadline_and_notify(next_task)
    end
  end

  def set_deadline_and_notify(next_task)
    next_action = next_task.get_company_action(self.company, self.workflow.identifier)
    next_action.update_columns(deadline: (Date.today + next_task.days_to_complete)) unless next_task.days_to_complete.nil?

    # Create new reminder based on deadline of action and repeat every 2 days
    create_reminder(next_task, next_action)

    # Trigger email notification for next task
    users = User.with_role(next_task.role.name.to_sym, self.company)
    NotificationMailer.deliver_notifications(next_task, next_action, users)
  end

  def create_reminder(task, action)
    Reminder.create(next_reminder: action.deadline, repeat: true, freq_value: 2, freq_unit: "days", company_id: action.company_id, task_id: task.id, company_action_id: action.id) if (task.set_reminder && action.deadline.present?)
  end

  def send_notification
    if self.completed
      SlackService.new.send_notification(self).deliver
    end
  end
end
