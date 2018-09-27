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

    def create_invoice_payable(contact_id, date, due_date, identifier, item_code, description, quantity, price, account)
      supplier = get_contact(contact_id)
      ap = @xero_client.Invoice.build(type: "ACCPAY", contact: supplier, date: Date.strptime(date, '%d-%b-%y'), due_date: Date.strptime(due_date, '%d-%b-%y'), invoice_number: identifier)
      ap.add_line_item(item_code: item_code, description: description, quantity: quantity, unit_amount: price, account_code: account)
      ap.save
      return ap
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