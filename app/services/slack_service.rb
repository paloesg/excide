class SlackService
  NAME_AND_ICON = {
    username: 'Excide Platform'
  }

  GOOD = 'good'
  WARNING = 'warning'
  DANGER = 'danger'

  def initialize(user=nil)
    if user.nil?
      @uri = URI(ENV['SLACK_WEBHOOK_URL'])
      @channel = ENV['SLACK_WEBHOOK_CHANNEL']
    else
      @uri = URI(user.company.slack_access_response['incoming_webhook']['url'])
      @channel = user.company.slack_access_response['incoming_webhook']['channel']
    end
  end

  def deliver
    begin
      Net::HTTP.post_form(@uri, @params)
    rescue => e
      Rails.logger.error("BespokeSlackbotService: Error when sending: #{e.message}")
    end
  end

  def task_notification(task, action, user)
    params = {
      attachments: [
        {
          title: action.workflow.template.title,
          fallback: 'Task ID ' + task.id.to_s,
          pretext: 'Please be reminded to perform this task:',
          color: WARNING,
          fields: [
            {
              title: 'Workflow Id',
              value: action.workflow.id,
              short: true
            },
            {
              title: 'Client',
              value: action.workflow.workflowable&.name,
              short: true
            },
            {
              title: 'Task',
              value: task.instructions,
            },
            {
              title: 'Assigned To',
              value: user.full_name,
              short: true
            },
          ]
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def company_signup(company)
    params = {
      attachments: [
        {
          title: "#{company.name} company has signed up for Overture!",
          fallback: 'A new company has signed up!',
          color: GOOD
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  private

  def generate_payload(params)
    {
      payload: NAME_AND_ICON
        .merge(channel: @channel)
        .merge(params).to_json
    }
  end
end
