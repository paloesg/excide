class NotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def self.deliver_notifications(task, action, users)
    users.each do |user|
      task_notification(task, action, user).deliver_now
    end
  end

  def task_notification(task, action, user)
    @task = task
    @action = action
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: 'You have a new task to complete')
  end

  def reminder_notification(reminder)
    @reminder = reminder
    @user = reminder.user

    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: @reminder.title)
  end
end
