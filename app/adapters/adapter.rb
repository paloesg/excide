module Adapter
  class Xero
    def initialize(company)
      @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "| echo \"#{ENV["XERO_PRIVATE_KEY"]}\" ")
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

    def create_invoice_payable(contact_id, date, due_date, line_items, line_amount_type, reference, currency)
      supplier = get_contact(contact_id)
      xero_line_amount_type = line_amount_type.camelize
      @tracking_name = get_tracking_options
      #date is in %d-%b-%y => 13-Feb-19 (Date-Month-Year in this format)
      @ap = @xero_client.Invoice.build(type: "ACCPAY", contact: supplier, date: date, due_date: due_date, line_amount_types: xero_line_amount_type, url: 'https://www.excide.co/symphony/', invoice_number: reference, currency_code: currency[0..2])
      line_items.each do |line_item|
        @tracking = [{name: @tracking_name[0]&.name, option: line_item.tracking_option_1}, {name: @tracking_name[1]&.name, option: line_item.tracking_option_2}]
        @ap.add_line_item(item_code: nil, description: line_item.description, quantity: line_item.quantity, unit_amount: line_item.price, account_code: line_item.account.slice(0..2), tax_type: line_item.tax.split.last, tracking: @tracking)
      end
      @ap.save!
      return @ap
    end

    def create_invoice_receivable(contact_id, date, due_date, reference)
      contact = get_contact(contact_id)
      @ar = @xero_client.Invoice.build(type: "ACCREC", contact: contact, date: date, due_date: due_date, reference: reference)
      order.order_products.each do |op|
        ar.add_line_item(item_code: op.product.sku, description: op.product.name ,quantity: op.quantity, unit_amount: op.price, account_code: account)
      end
      ar.save
      return ar.invoice_id
    end
  end
end
