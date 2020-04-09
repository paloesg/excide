# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
#you can either log in to User.last account or change the User.last to User.find(your id)
class NotificationMailerPreview < ActionMailer::Preview
  def first_task_notification
    NotificationMailer.first_task_notification(Task.last, Batch.last, User.last)
  end

  def unordered_workflow_notification
    NotificationMailer.unordered_workflow_notification(Template.where(workflow_type: 1).first.workflows.first.user, Template.where(workflow_type: 1).first.sections.map{|sect| sect.tasks }.flatten.compact, WorkflowAction.last)
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
