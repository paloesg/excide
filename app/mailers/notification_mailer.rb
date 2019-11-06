class NotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def sign_up_notification(user)
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: 'Please activate your Excide Symphony account')
  end

  def task_notification(task, action, user)
    @task = task
    @action = action
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: '[New Task] ' + @task.section.template.title + ' - ' + @action.workflow.id)
  end

  def first_task_notification(task, batch, user)
    @task = task
    @batch = batch
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: '[New Task] ' + @task.instructions + ' - ' + @batch.id)
  end

  def unordered_workflow_notification(user, workflow_tasks, action)
    @user = user
    #find relevant tasks through intersection that the particular user have in that workflow
    @relevant_tasks = @user.roles.map(&:tasks).flatten & workflow_tasks
    @action = action
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: '[New Task] Unordered Workflow - '+ @relevant_tasks[0].section.section_name + ' - ' + @action.workflow.id)
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

  def create_event(event, user)
    event_notification(event, user, 'A new event has been created')
  end

  def edit_event(event, user)
    event_notification(event, user, 'An event has been changed')
  end

  def destroy_event(event, user)
    event_notification(event, user, 'An event has been cancelled')
  end

  def user_removed_from_event(event, user)
    event_notification(event, user, "Unassigned: #{event.name} #{event.start_time.strftime("%F")} #{event.start_time.strftime("%H:%M")} - #{event.end_time.strftime("%H:%M")}")
  end

  def event_notification(event, user, subject)
    @user = user
    @subject = subject
    @event = event
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: @subject)
  end

  def associate_notification(user)
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: 'Assign your availability for the next month')
  end
end