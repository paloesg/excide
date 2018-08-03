class SlackService
  NAME_AND_ICON = {
    username: 'Excide Platform'
  }

  GOOD = 'good'
  WARNING = 'warning'
  DANGER = 'danger'

  def initialize(uri = URI(ENV['SLACK_WEBHOOK_URL']), channel = ENV['SLACK_WEBHOOK_CHANNEL'])
    @uri = uri
    @channel = channel
  end

  def new_enquiry(enquiry)
    params = {
      attachments: [
        {
          title: 'Enquiry Details',
          title_link: 'https://' + ENV['HOST_DOMAIN'] + '/admin/enquiries/' + enquiry.id.to_s,
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

  def new_document(document)
    params = {
      attachments: [
        {
          title: document.filename,
          fallback: 'New document uploaded: ' + document.filename,
          pretext: 'A new document has been uploaded:',
          color: GOOD,
          fields: [
            {
              title: 'Document Identifier',
              value: document.identifier,
              short: true
            },
            {
              title: 'Filetype',
              value: File.extname(document.file_url),
              short: true
            },
            {
              title: 'Workflow Identifier',
              value: document.workflow&.identifier || '-',
              short: true
            },
            {
              title: 'Company',
              value: document.company&.name || '-',
              short: true
            },
            {
              title: 'Link',
              value: 'https://' + ENV['HOST_DOMAIN'] + '/symphony/documents/' + document.id.to_s,
            }
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
          title_link: 'https://' + ENV['HOST_DOMAIN'] + '/admin/enquiries/' + enquiry.id.to_s,
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
          title_link: 'https://' + ENV['HOST_DOMAIN'] + '/admin/reminders/' + reminder.id.to_s,
          fallback: 'Reminder ID ' + reminder.id.to_s,
          pretext: 'Please send a reminder to the following client.',
          color: WARNING,
          fields: [
            {
              title: 'Client',
              value: reminder.company.name,
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

  def send_reminders(reminders, user)
    fields = []
    reminders.each do |reminder|
      fields << { title: reminder.title, value: reminder.content }
    end

    params = {
      attachments: [
        {
          pretext: 'Reminders for ' + user.first_name + ' today:',
          color: WARNING,
          fields: fields
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def send_reminder_error(reminder, error)
    params = {
      attachments: [
        {
          title: 'Error sending reminder',
          color: WARNING,
          fallback: 'Error sending reminder ID ' + reminder.id.to_s,
          fields: [
            {
              title: 'Reminder ID',
              value: reminder.id.to_s
            },
            {
              title: 'Error Message',
              value: error.to_s
            }
          ]
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def send_notification(action)
    params = {
      attachments: [
        {
          title: action.workflow.template.title,
          fallback: 'Task ID ' + action.task.id.to_s,
          pretext: 'A task has been completed:',
          color: GOOD,
          fields: [
            {
              title: 'Workflow Identifier',
              value: action.workflow.identifier,
              short: true
            },
            {
              title: 'Client',
              value: action.workflow.workflowable&.name,
              short: true
            },
            {
              title: 'Task',
              value: action.task.instructions,
            },
            {
              title: 'Assigned To',
              value: action.assigned_user&.full_name || '-',
              short: true
            },
            {
              title: 'Completed By',
              value: action.completed_user&.full_name,
              short: true
            },
          ]
        }
      ]
    }
    @params = generate_payload(params)
    self
  end

  def user_signup(user)
    params = {
      attachments: [
        {
          title: 'A new user has signed up!',
          fallback: 'A new user has signed up!',
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