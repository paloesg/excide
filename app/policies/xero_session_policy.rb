class XeroSessionPolicy < Struct.new(:user, :xero_session)

  def connect_to_xero?
    user.company.pro? or user.company.free_trial?
  end
  
  def update_contacts_from_xero?
    user.company.pro? or user.company.free_trial?
  end

  def update_line_items_from_xero?
    user.company.pro? or user.company.free_trial?
  end
end
