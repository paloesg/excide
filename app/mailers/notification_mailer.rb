class NotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def self.deliver_notifications(next_task, action, users)
    users.each do |user|
      task_notification(next_task, action, user).deliver_later
    end
  end

  def task_notification(task, action, user)
    @task = task
    @action = action
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: '[New Task] ' + @task.section.template.title + ' - ' + @action.workflow.id)
  end

  def unordered_workflow_notification(user, workflow_tasks, action)
    @user = user
    #find relevant tasks through intersection that the particular user have in that workflow
    @relevant_tasks = @user.roles.map(&:tasks).flatten & workflow_tasks
    @action = action
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: '[New Task] ' + 'Unordered Workflow - ' + @action.workflow.id)
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