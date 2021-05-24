module Motif::FranchiseesHelper
  def get_franchisee
    # The first condition checks for unit franchisee or sub franchisee, which company is the entity 1 level higher, resulting in wrong license_type to display. Therefore, we check for the active_outlet franchisee instead.
    if current_user.active_outlet.present?
      # All outlet manager should show designated user label
      nil
    else
      Franchisee.find_by(franchisee_company: current_user.company)
    end
  end
end
