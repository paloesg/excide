module Motif::OutletsHelper
  def get_outlets_by_type(type, company)
    if type.present?
      if type == "direct-owned"
        # Get all outlets of the company (direct owned)
        Outlet.includes(:company).where(company_id: company).order("created_at asc")
      else
        # Get all outlets from 1 layer down (master franchisee or area franchisee). Add condition to check for unit franchisee and remove them from queries
        Outlet.includes(:franchisee).where(franchisees: { company_id: company.id}).where.not( franchisees: { license_type: "unit_franchisee"})
      end
    else
      # Add all outlets (direct-owned or sub franchised)
      Outlet.includes(:company).where(company_id: company).order("created_at asc") + Outlet.includes(:franchisee).where(franchisees: { company_id: company.id}).where.not( franchisees: { license_type: "unit_franchisee"})
    end
  end
end
