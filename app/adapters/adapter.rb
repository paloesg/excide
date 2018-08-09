module Adapter
  class Xero
    def initialize(session)
      @xero_client = Xeroizer::PublicApplication.new(ENV['XERO_CONSUMER_KEY'], ENV['XERO_CONSUMER_SECRET'])

      if session[:xero_auth]
        @xero_client.authorize_from_access(
          session[:xero_auth]["access_token"],
          session[:xero_auth]["access_key"]
        )
      end
    end

    def get_contacts
      @xero_client.Contact.all
    end
  end
end