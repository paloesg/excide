module Motif::HomeHelper
  def check_unit_franchisee_or_franchisee_owner?
    if Franchisee.find_by(franchisee_company: current_user.company).present?
      # check if current user is franchisee owner (outlet manager) or franchisee is unit_franchisee
      current_user.has_role?(:franchisee_owner, current_user.company) or Franchisee.find_by(franchisee_company: current_user.company).unit_franchisee?
    end
  end
end
