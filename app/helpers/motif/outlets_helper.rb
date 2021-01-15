module Motif::OutletsHelper
  def get_outlets_by_type(type, company)
    # get_outlets method retrieves all outlets (sub franchised or direct owned) and it is not restricted by company
    if type.present?
      if type == "direct-owned"
        Outlet.includes(:company).where(company_id: company).order("created_at asc")
      else
        Outlet.includes(:franchisee).where(franchisees: {franchise_licensee: company.name})
      end
    else
      # Outlets that are directly under the entity + outlets for MF to manage
      Outlet.includes(:company).where(company_id: company).order("created_at asc") + Outlet.includes(:franchisee).where(franchisees: {franchise_licensee: company.name})
    end
  end
end
