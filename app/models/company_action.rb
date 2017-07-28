class CompanyAction < ActiveRecord::Base
  after_save :set_deadline_and_reminders
  after_save :send_notification, if: :completed_changed?

  belongs_to :task
  belongs_to :company

  has_one :reminder

  private

  def set_deadline_and_reminders
    if self.completed
      # Find associated reminders and remove next reminder date
      self.reminder.update_attributes(next_reminder: nil) if self.reminder.present?

      unless self.task.last?
        # Find next action in line and set deadline if not the last task in section
        next_task = self.task.lower_item
        next_action = next_task.get_company_action(self.company)
        next_action.update_columns(deadline: (Date.today + next_task.days_to_complete)) unless next_task.days_to_complete.nil?

        # Create new reminder based on deadline of action and repeat every 2 days
        create_reminder(next_task, next_action)
      end
    elsif self.task.first? && self.reminder.nil?
      # If task is first in the list, create own reminder
      self.update_columns(deadline: (Date.today + self.task.days_to_complete)) unless self.task.days_to_complete.nil?
      create_reminder(self.task, self)
    end
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
