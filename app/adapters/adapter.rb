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

    def create_contact(client)
      xero_contact = @xero_client.Contact.build(name: client[:name])
      xero_contact.save!
      return xero_contact.contact_id
    end

    def get_accounts
      @xero_client.Account.all
    end

    def create_invoice_payable(contact_id, date, due_date, identifier, lineitems)
      supplier = get_contact(contact_id)
      #date is in %d-%b-%y => 13-Feb-19 (Date-Month-Year in this format)
      @ap = @xero_client.Invoice.build(type: "ACCPAY", contact: supplier, date: date, due_date: due_date, invoice_number: identifier, url: 'https://www.excide.co/symphony/')
      lineitems.each do |lineitem|
        @ap.add_line_item(item_code: nil, description: lineitem.description, quantity: lineitem.quantity, unit_amount: lineitem.price, account_code: lineitem.account)
      end
      @ap.save
      return @ap
    end

    def create_invoice_receivable(type, contact, date, due_date, reference, order, account)
      ar = @xero_client.Invoice.build(type: type, contact: contact, date: date, due_date: due_date, reference: reference)
      order.order_products.each do |op|
        ar.add_line_item(item_code: op.product.sku, description: op.product.name ,quantity: op.quantity, unit_amount: op.price, account_code: account)
      end
      ar.save
      return ar.invoice_id
    end
  end
end