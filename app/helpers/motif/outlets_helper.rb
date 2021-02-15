module Motif::OutletsHelper
  def get_outlets_by_type(type, company)
    if type.present?
      if type == "direct-owned"
        # Get all outlets of the company (direct owned)
        Outlet.includes(:company, :franchisee).where(company_id: company).where(franchisees: { franchise_licensee: ""})
      else
        # Get children's direct-owned outlets (where franchise_licensee is empty). The second part of the equation gets company's own unit_franchisee & sub_franchisee as these are not a company entity, hence we could not call company.children.
        # Should NOT get children's unit franchisee outlets
        company.children.includes(outlets: [:franchisee]).where(outlets: { franchisees: { franchise_licensee: ""}}).map(&:outlets).flatten + company.franchisees.where(license_type: ["unit_franchisee", "sub_franchisee"]).map(&:outlets).flatten
      end
    else
      # Add all outlets (direct-owned or sub franchised)
      Outlet.includes(:company).where(company_id: company).order("created_at asc") + company.children.includes(outlets: [:franchisee]).where(outlets: { franchisees: { franchise_licensee: ""}}).map(&:outlets).flatten
    end
  end
end
