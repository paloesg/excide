module Overture::ContactsHelper
  def get_cloned_contact(contact)
    # Params contact is the searchable contact. If there is another contact with the same company_name and is not cloned_by: nil, then it is a cloned contact.
    # It returns the contact record
    Contact.where(company_name: contact.company_name).where.not(cloned_by: nil)
  end
end
