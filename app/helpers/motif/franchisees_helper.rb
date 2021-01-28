module Motif::FranchiseesHelper
  def get_franchisee
    # The first condition checks for unit franchisee or sub franchisee, which company is the entity 1 level higher, resulting in wrong license_type to display. Therefore, we check for the active_outlet franchisee instead.
    if current_user.active_outlet.present?
      # Check if license_type exist. If not, it means the outlet is direct owned to the franchisor or higher level
      if current_user.active_outlet.franchisee.license_type.present?
        current_user.active_outlet.franchisee
      else
        nil
      end
    else
      Franchisee.find_by(franchise_licensee: current_user.company.name)
    end
  end
end
