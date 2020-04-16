module Symphony::InvoicesHelper
  def update_xero_contacts(xero_contact_name, xero_contact_id, invoice, clients)
    if xero_contact_name.blank?
      invoice.xero_contact_name = clients.find_by(contact_id: xero_contact_id).name
    else
      invoice.xero_contact_id = @xero.create_contact(name:xero_contact_name)
      xero_contact = XeroContact.create(name: xero_contact_name, contact_id: invoice.xero_contact_id, company: @company)
    end
    invoice.save
  end
  
end
