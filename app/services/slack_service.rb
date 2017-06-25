class SlackService
  NAME_AND_ICON = {
    username: 'Excide Platform'
  }

  GOOD = 'good'
  WARNING = 'warning'
  DANGER = 'danger'

  def initialize(channel = ENV['SLACK_WEBHOOK_CHANNEL'])
    @uri = URI(ENV['SLACK_WEBHOOK_URL'])
    @channel = channel
  end

  def new_enquiry(enquiry)
    params = {
      attachments: [
        {
          title: 'Enquiry Details',
          title_link: 'https://' + ENV['APP_NAME'] + '.herokuapp.com/admin/enquiries/' + enquiry.id.to_s,
          fallback: 'There is a new enquiry with ID ' + enquiry.id.to_s,
          pretext: 'Yay! There is a new enquiry from the website.',
          color: GOOD,
          fields: [
            {
              title: 'Name',
              value: enquiry.name,
              short: true
            },
            {
              title: 'Source',
              value: enquiry.source,
              short: true
            },
            {
              title: 'Contact Number',
              value: enquiry.contact || '-',
              short: true
            },
            {
              title: 'Email',
              value: enquiry.email,
              short: true
            },
            {
              title: 'Message',
              value: enquiry.comments || '-'
            },
          ]
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def auto_response(enquiry)
    params = {
      attachments: [
        {
          title: 'Automated Enquiry Response',
          title_link: 'https://' + ENV['APP_NAME'] + '.herokuapp.com/admin/enquiries/' + enquiry.id.to_s,
          fallback: 'An automated email has been sent to enquiry with ID ' + enquiry.id.to_s,
          pretext: 'An automated email response has been sent to this enquiry.',
          color: GOOD,
          fields: [
            {
              title: 'Name',
              value: enquiry.name,
              short: true
            },
            {
              title: 'Source',
              value: enquiry.source,
              short: true
            },
            {
              title: 'Email',
              value: enquiry.email,
              short: true
            },
            {
              title: 'Response Sent',
              value: enquiry.responded || '-',
              short: true
            },
          ]
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def send_reminder(reminder)
    params = {
      attachments: [
        {
          title: 'Reminder',
          title_link: 'https://' + ENV['APP_NAME'] + '.herokuapp.com/admin/reminders/' + reminder.id.to_s,
          fallback: 'Reminder ID ' + reminder.id.to_s,
          pretext: 'Please send a reminder to the following client.',
          color: WARNING,
          fields: [
            {
              title: 'Client',
              value: reminder.company.name,
              short: true
            },
            {
              title: 'Email',
              value: reminder.company.user.email,
              short: true
            },
            {
              title: 'Title',
              value: reminder.title,
            },
            {
              title: 'Message',
              value: reminder.content,
            },
          ]
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def consultant_signup(user, profile)
    params = {
      attachments: [
        {
          title: 'A new consultant has signed up!',
          fallback: 'A new consultant has signed up!',
          color: GOOD
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def company_signup(user, company)
    params = {
      attachments: [
        {
          title: 'A new company has signed up!',
          fallback: 'A new company has signed up!',
          color: GOOD
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def deliver
    begin
      Net::HTTP.post_form(@uri, @params)
    rescue => e
      Rails.logger.error("BespokeSlackbotService: Error when sending: #{e.message}")
    end
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