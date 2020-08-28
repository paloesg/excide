class SendDailySummary
    include Service
  
    def initialize(user)
      @user = user
      @from_number = ENV['TWILIO_NUMBER']
      @account_sid = ENV['TWILIO_ACCOUNT_SID']
      @auth_token = ENV['TWILIO_AUTH_TOKEN']
      @client = Twilio::REST::Client.new @account_sid, @auth_token
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
      @email_summary_notifications = WorkflowAction.includes(:workflow).all_user_actions(@user).where.not(completed: true, deadline: nil).where(current_action: true).order(:company_id, :deadline).includes(:task)
    end

    def send_daily_summary
      @companies = []
      @email_summary_notifications.each do |email_summary_notification|
        @companies << email_summary_notification.company
      end
      @companies = @companies.uniq
      NotificationMailer.daily_summary(@email_summary_notifications, @user, @companies).deliver_now if @user.settings[0]&.reminder_email == 'true'
    end
  end
  