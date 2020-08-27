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
      #return OpenStruct.new(success?:true, notifications_count: 0, user: @user, message: 'No reminders for this user.') if @email_summary_notifications.empty?
      send_daily_summary
      #return OpenStruct.new(success?:true, notifications_count: @email_summary_notifications.count, user: @user, message: 'Reminders for this user sent.')
    end
  
    private
  
    # query from each of user's companies
    # get the workflow_actions of the companies
    # ensure that the workflow_actions' previous step is alr completed
    # order the workflow_actions in ascending deadline 
    # continue to next company
    def get_user_notifications_draft
      #@reminders = Reminder.today.where(user: @user)
      @email_summary_notifications = []
      @user.company.each do |company|
        @sorted_company_workflow_actions = []
        @company_workflow_actions = company.workflow_actions.where(user: @user, )

        # INSERT VALIDATION FOR PREV STEP COMPLETION
        @company_workflow_actions.each do |company_workflow_action|
            # gets the first incomplete workflow_action (aka the one next up) in the task
            first_incomplete_workflow_action = company_workflow_action.task.workflow_actions.where(completed: false).first  #not sure about the ordering, first may not return the next workflow_action

            #checks if the company_workflow_action is indeed the next workflow_action to be completed
            if first_incomplete_workflow_action == company_workflow_action && company_workflow_action.deadline != null
                @sorted_company_workflow_actions.concat(company_workflow_action)
            end
        end


        @sorted_company_workflow_actions = @sorted_company_workflow_actions.sort_by { |sorted_company_workflow_action| sorted_company_workflow_action.deadline }
        @email_summary_notifications.concat(@sorted_company_workflow_actions)
      end
    end
    
    # using app/controllers/symphony/home_controller.rb querying method
    
    def get_user_notifications
      @email_summary_notifications
      @user_actions = WorkflowAction.includes(:workflow).all_user_actions(@user).where.not(completed: true, deadline: nil).where(current_action: true).order(:company_id, :deadline).includes(:task)
      

      
      @email_summary_notifications = @user_actions
    end

    def send_daily_summary
      #email_reminders = @reminders.where(email: true)
      #email_reminders[0]&.notify :users, key: "reminder.send_reminder", parameters: { reminders: email_reminders }, send_later: false
      NotificationMailer.daily_summary(@email_summary_notifications, @user).deliver_now if @user.settings[0]&.reminder_email == 'true'
    end
  end
  