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
                title: 'There is a new enquiry!',
                fallback: 'There is a new enquiry!',
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
                        value: enquiry.contact,
                        short: true
                    },
                    {
                        title: 'Email',
                        value: enquiry.email,
                        short: true
                    },
                    {
                        title: 'Message',
                        value: enquiry.comments
                    },
                ]
            }
        ]
    }
    @params = generate_payload(params)
    self
  end

  def send_reminder(business)
    params = {
        attachments: [
            {
                title: 'A reminder has been sent',
                fallback: 'A reminder has been sent',
                color: GOOD,
                fields: [
                    {
                        title: 'Client',
                        value: business.name
                    },
                    {
                        title: 'Email',
                        value: business.user.email
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
                color: GOOD,
                fields: [
                    {
                        title: 'First Name',
                        value: user.first_name,
                        short: true
                    },
                    {
                        title: 'Last Name',
                        value: user.last_name,
                        short: true
                    },
                    {
                        title: 'Email',
                        value: user.email,
                        short: true
                    },
                    {
                        title: 'Phone',
                        value: user.contact_number,
                        short: true
                    },
                    {
                        title: 'Headline',
                        value: profile.headline
                    },
                    {
                        title: 'Summary',
                        value: profile.summary
                    },
                    {
                        title: 'Industry',
                        value: profile.industry,
                        short: true
                    },
                    {
                        title: 'Specialties',
                        value: profile.specialties,
                        short: true
                    },
                    {
                        title: 'Location',
                        value: profile.location,
                        short: true
                    },
                    {
                        title: 'Country Code',
                        value: profile.country_code,
                        short: true
                    },
                    {
                        title: 'LinkedIn URL',
                        value: profile.linkedin_url
                    }
                ]
            }
        ]
    }
    @params = generate_payload(params)
    self
  end

  def business_signup(user, business)
    params = {
        attachments: [
            {
                title: 'A new business has signed up!',
                fallback: 'A new business has signed up!',
                color: GOOD,
                fields: [
                    {
                        title: 'First Name',
                        value: user.first_name,
                        short: true
                    },
                    {
                        title: 'Last Name',
                        value: user.last_name,
                        short: true
                    },
                    {
                        title: 'Email',
                        value: user.email,
                        short: true
                    },
                    {
                        title: 'Phone',
                        value: user.contact_number,
                        short: true
                    },
                    {
                        title: 'Company',
                        value: business.name
                    },
                    {
                        title: 'Description',
                        value: business.description
                    },
                    {
                        title: 'Industry',
                        value: business.industry,
                        short: true
                    },
                    {
                        title: 'Company Type',
                        value: business.company_type,
                        short: true
                    },
                    {
                        title: 'LinkedIn URL',
                        value: business.linkedin_url
                    }
                ]
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