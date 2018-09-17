class NotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def self.deliver_notifications(task, action, users)
    users.each do |user|
      task_notification(task, action, user).deliver_later
    end
  end

  def task_notification(task, action, user)
    @task = task
    @action = action
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: '[New Task] in ' + @task.section.template.title + ' - ' + @action.workflow.identifier)
  end

  def reminder_notification(reminder)
    @reminder = reminder
    @user = reminder.user

    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: @reminder.title)
  end

  def batch_reminder(reminders, user)
    @reminders = reminders
    @user = user

    address = Mail::Address.new @user.email
    address.display_name = @user.first_name
    mail(to: address.format, subject: 'Here are your reminders for today')
  end

  def create_activation(activation, user)
    activation_notification(activation, user, 'A new activation has been created')
  end

  def edit_activation(activation, user)
    activation_notification(activation, user, 'An activation has been changed')
  end

  def destroy_activation(activation, user)
    activation_notification(activation, user, 'An activation has been cancelled')
  end

  def user_removed_from_activation(activation, user)
    activation_notification(activation, user, "Unassigned: #{activation.name} #{activation.start_time.strftime("%F")} #{activation.start_time.strftime("%H:%M")} - #{activation.end_time.strftime("%H:%M")}")
  end

  def activation_notification(activation, user, subject)
    @user = user
    @subject = subject
    @activation = activation
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: @subject)
  end

  def contractor_notification(user)
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: 'Assign your availability for the next month')
  end
end
