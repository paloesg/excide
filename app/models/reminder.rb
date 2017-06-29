class Reminder < ActiveRecord::Base
  require 'twilio-ruby'

  belongs_to :user
  belongs_to :company

  enum freq_unit: [:days, :weeks, :months, :years]

  def self.today
    reminders = Reminder.where('DATE(next_reminder) = ?', Date.today)
  end

  def send_reminder
    SlackService.new.send_reminder(self).deliver
    @client = ::Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d, %Y")
    reminder = "Hi #{self.user.first_name}. Just a reminder: #{self.title}."
    message = @client.account.messages.create(
      :from => ENV['TWILIO_NUMBER'],
      :to => self.user.contact_number,
      :body => reminder,
    )
    if self.repeat?
      self.next_reminder = Date.today + self.freq_value.to_i.send(self.freq_unit)
    else
      self.next_reminder = nil
    end
    self.save
  end
end
