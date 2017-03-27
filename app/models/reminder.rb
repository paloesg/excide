class Reminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :business

  enum freq_unit: [:days, :weeks, :months, :years]

  def self.today
    reminders = Reminder.where('DATE(next_reminder) = ?', Date.today)
  end

  def send_reminder
    SlackService.new.send_reminder(self.business).deliver
    if self.repeat?
      self.next_reminder = Date.today + self.freq_value.to_i.send(self.freq_unit)
    else
      self.next_reminder = nil
    end
    self.save
  end
end
