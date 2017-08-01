class Reminder < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  belongs_to :user
  belongs_to :company
  belongs_to :task
  belongs_to :company_action

  enum freq_unit: [:days, :weeks, :months, :years]

  def self.today
    reminders = Reminder.where('DATE(next_reminder) = ?', Date.today)
  end

  def send_reminder
    SlackService.new.send_reminder(self).deliver
    if self.repeat?
      self.next_reminder = Date.today + self.freq_value.to_i.send(self.freq_unit)
    else
      self.next_reminder = nil
    end
    self.save
  end
end
