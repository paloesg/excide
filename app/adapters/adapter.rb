module Adapter
  class Xero
    def initialize(xero_auth)
      @xero_client = Xeroizer::PublicApplication.new(ENV['XERO_CONSUMER_KEY'], ENV['XERO_CONSUMER_SECRET'])

      if xero_auth
        @xero_client.authorize_from_access(
          xero_auth["access_token"],
          xero_auth["access_key"]
        )
      end
    end

    def get_contacts
      @xero_client.Contact.all
    end

    def get_contact(xero_contact_id)
      return contact = @xero_client.Contact.find(xero_contact_id)
    end

    def get_accounts
      @xero_client.Account.all
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
        if line_item.tracking_option2.present?
          @tracking = [{name: @tracking_name[0].name, option: line_item.tracking_option1}, {name: @tracking_name[1].name, option: line_item.tracking_option2}]
        elsif line_item.tracking_option1.present? and line_item.tracking_option2.nil?
          @tracking = [{name: @tracking_name[0].name, option: line_item.tracking_option1}]
        else
          @tracking = nil
        end
        @ap.add_line_item(item_code: nil, description: line_item.description, quantity: line_item.quantity, unit_amount: line_item.price, account_code: line_item.account, tax_type: line_item.tax, tracking: @tracking)
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