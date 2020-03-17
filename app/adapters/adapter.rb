module Adapter
  class Xero
    include Rails.application.routes.url_helpers
    def initialize(company)
      # Sleep for 2 seconds every time the rate limit is exceeded.
      @xero_client = Xeroizer::PartnerApplication.new(
        ENV["XERO_CONSUMER_KEY"],
        ENV["XERO_CONSUMER_SECRET"],
        "| echo \"#{ENV["XERO_PRIVATE_KEY"]}\" ",
        :rate_limit_sleep => 2,
        before_request: ->(request) {
          request.headers.merge! "User-Agent" => ENV['XERO_CONSUMER_KEY']
        }
      )
      #check for token expiring and renew it. After renew, update company's attribute
      if company.expires_at.present? and (Time.at(company.expires_at) < Time.now)
        @xero_client.renew_access_token(company.access_key, company.access_secret, company.session_handle)
        company.update_attributes(expires_at: @xero_client.client.expires_at, access_key: @xero_client.access_token.token, access_secret: @xero_client.access_token.secret, session_handle: @xero_client.session_handle)
      end
      if company
        @xero_client.authorize_from_access(
          company.access_key,
          company.access_secret
        )
      end
    end

#-----------------------------------------Used in xero_sessions_controller.rb-----------------------------------------------
    def request_token(invoice_params={})
      if invoice_params.nil?
        @xero_client.request_token(oauth_callback: ENV['ASSET_HOST'] + '/xero_callback_and_update')
      else
        @xero_client.request_token(oauth_callback: ENV['ASSET_HOST'] + xero_callback_and_update_path(workflow_action_id: invoice_params[:workflow_action_id], workflow_id: invoice_params[:workflow_id], invoice_type: invoice_params[:invoice_type]))
      end
    end

    def authorize_from_request(request_token, request_secret, oauth_verifier)
      @xero_client.authorize_from_request(request_token, request_secret, oauth_verifier: oauth_verifier)
    end

    def update_company_after_connecting_to_xero(company)
      company.update(expires_at: @xero_client.client.expires_at, access_key: @xero_client.access_token.token, access_secret: @xero_client.access_token.secret, session_handle: @xero_client.session_handle, xero_organisation_name: @xero_client.Organisation.first.name)
    end

    def save_xero_contacts(company)
      @xero_client.Contact.all.each do |contact|
        xc = XeroContact.find_or_initialize_by(contact_id: contact.contact_id)
        xc.update(name: contact.name, company: company)
      end
    end

    def save_xero_line_items(company)
      @xero_client.Item.all.each do |item|
        xli = XeroLineItem.find_or_initialize_by(item_code: item.code)
        xli.update(description: item.description, quantity: item.quantity_on_hand, price: item.sales_details.unit_price, account: item.sales_details.account_code, tax: item.sales_details.tax_type, company: company)
      end
    end
#---------------------------------------------------------------------------------------------------------------------------
    def get_organisation
      @xero_client.Organisation.first
    end

    def get_contacts
      @xero_client.Contact.all
    end

    def get_items
      @xero_client.Item.all
    end

    def get_item_attributes(item_code)
      @xero_client.Item.all(:where => {:code => item_code})
    end

    def get_contact(xero_contact_id)
      return @xero_client.Contact.find(xero_contact_id)
    end

    def get_invoice(xero_invoice_id)
      return @xero_client.Invoice.find(xero_invoice_id)
    end

    def get_accounts
      @xero_client.Account.all
    end

    def get_account_attributes(account_code)
      @xero_client.Account.all(:where => {:code => account_code})
    end

    def get_tax_rates
      @xero_client.TaxRate.all
    end

    def get_currencies
      @xero_client.Currency.all
    end

    def get_tracking_options
      @xero_client.TrackingCategory.all
    end

    def create_contact(client)
      xero_contact = @xero_client.Contact.build(name: client[:name])
      xero_contact.save!
      return xero_contact.contact_id
    end

    def create_invoice(contact_id, date, due_date, line_items, line_amount_type, reference, currency, invoice_type)
      contact = get_contact(contact_id)
      xero_line_amount_type = line_amount_type.camelize
      tracking_name = get_tracking_options
      if invoice_type == "payable"
        #date is in %d-%b-%y => 13-Feb-19 (Date-Month-Year in this format)
        inv = @xero_client.Invoice.build(type: "ACCPAY", contact: contact, date: date, due_date: due_date, line_amount_types: xero_line_amount_type, url: "https://www.excide.co/symphony/", invoice_number: reference, currency_code: currency[0..2])
      else
        inv = @xero_client.Invoice.build(type: "ACCREC", contact: contact, date: date, due_date: due_date, line_amount_types: xero_line_amount_type, url: "https://www.excide.co/symphony/", invoice_number: reference, currency_code: currency[0..2])
      end
      line_items.each do |line_item|
        tracking = [{name: tracking_name[0]&.name, option: line_item.tracking_option_1}, {name: tracking_name[1]&.name, option: line_item.tracking_option_2}]
        inv.add_line_item(item_code: nil, description: line_item.description, quantity: line_item.quantity, unit_amount: line_item.price, account_code: line_item.account.slice(0..2), tax_type: line_item.tax.split.last, tracking: tracking)
      end
      inv.save
      return inv
    end

    def updating_invoice_payable(xero_invoice, updated_line_items)
      #update line item with the rounding line item
      rounding_line_item = updated_line_items.last
      xero_invoice.add_line_item(item_code: nil, description: rounding_line_item.description, quantity: rounding_line_item.quantity, unit_amount: rounding_line_item.price, account_code: rounding_line_item.account&.slice(0..2), tax_type: rounding_line_item.tax&.split&.last, tracking: nil)
      xero_invoice.save
    end
  end
end
