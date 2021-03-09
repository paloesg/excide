module Overture::ContactsHelper
  def get_cloned_contact(contact, user)
    # Params contact is the searchable contact. If there is another contact with the same company_name and is cloned_by current user's company, then it is a cloned contact.
    # It returns the contact record
    Contact.where(company_name: contact.company_name, cloned_by_id: contact.company.present? ? user.company.id : nil)
  end
end
