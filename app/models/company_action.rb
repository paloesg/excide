class CompanyAction < ActiveRecord::Base
  after_save :set_deadline_and_reminders, if: :completed_changed?

  belongs_to :task
  belongs_to :company

  has_one :reminder

  private

  def set_deadline_and_reminders
    if self.completed
      # Find associated reminders and remove next reminder date
      self.reminder.update_attributes(next_reminder: nil) if self.reminder.present?

      # Find next action in line and set deadline
      next_task = self.task.lower_item
      next_action = next_task.get_company_action(self.company)
      next_action.update_attributes(deadline: Date.today + next_task.days_to_complete) unless next_task.days_to_complete.nil?

      # Create new reminder based on deadline of action and repeat every 2 days
      Reminder.create(next_reminder: next_action.deadline, repeat: true, freq_value: 2, freq_unit: "days", company_id: self.company_id, task_id: next_task.id, company_action_id: self.id)
    end
  end
end
