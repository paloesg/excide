class SendDailySummary
  include Service
  include Rails.application.routes.url_helpers

  def initialize(user)
    @user = user
  end

  def run
    get_user_notifications
    return OpenStruct.new(success?:true, notifications_count: 0, user: @user, message: 'No notifications for this user.') if @email_summary_notifications.empty?
    send_daily_summary
    return OpenStruct.new(success?:true, notifications_count: @email_summary_notifications.length, user: @user, message: 'Notifications for this user sent.')
  end

  private

  # using app/controllers/symphony/home_controller.rb querying method
  def get_user_notifications
    @email_summary_notifications = WorkflowAction.includes(:workflow).all_user_actions(@user).where.not(completed: true, deadline: nil, current_action: false).order(:company_id, :deadline).includes(:task)
  end

  def send_daily_summary
    @action_details = []
    @email_summary_notifications.each do |email_summary_notification|
      @action_details << { 
        deadline: email_summary_notification.deadline.strftime('%F'), 
        task_instruction: email_summary_notification.task.instructions, 
        overdue: email_summary_notification.get_overdue_status_colour == "text-danger" ? true : false,
        not_overdue: email_summary_notification.get_overdue_status_colour == "text-primary" ? true : false, 
        due_soon: email_summary_notification.get_overdue_status_colour == "text-warning" ? true : false, 
        company_name: email_summary_notification.company.name, 
        link_address: "#{ENV['ASSET_HOST'] + symphony_workflow_path(email_summary_notification.task.section.template.slug, email_summary_notification.workflow.friendly_id)}" }.as_json
    end
    # Add link to email template for user to change notification settings
    link = "#{ENV['ASSET_HOST'] + notification_settings_symphony_user_path(@user)}"
    NotificationMailer.daily_summary(@action_details, @user, link).deliver_now if @user.settings[0]&.reminder_email == 'true'
  end
end
  
