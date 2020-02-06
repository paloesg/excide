class NotificationMailerPreview < ActionMailer::Preview
  def task_notification
    NotificationMailer.task_notification(Task.last, WorkflowAction.last, User.last)
  end

  def first_task_notification
    NotificationMailer.first_task_notification(Task.last, Batch.last, User.last)
  end

  def unordered_workflow_notification
    NotificationMailer.unordered_workflow_notification(Template.where(workflow_type: 1).first.workflows.first.user, Template.where(workflow_type: 1).first.sections.map{|sect| sect.tasks }.flatten.compact, WorkflowAction.last)
  end

  def reminder_notification
    NotificationMailer.reminder_notification(Reminder.last)
  end

  def batch_reminder
    NotificationMailer.batch_reminder(Reminder.where(user: User.last), User.last)
  end

  def create_event
    NotificationMailer.create_event(Event.last, User.last)
  end

  def edit_event
    NotificationMailer.edit_event(Event.last, User.last)
  end

  def destroy_event
    NotificationMailer.destroy_event(Event.last, User.last)
  end

  def user_removed_from_event
    NotificationMailer.user_removed_from_event(Event.last, User.last)
  end

  def associate_notification
    NotificationMailer.associate_notification(User.last)
  end

  def free_trial_ending_notification
    NotificationMailer.free_trial_ending_notification(User.last)
  end

end