module Motif::OutletsHelper
  def get_outlets_by_type(type, company)
    if type.present?
      if type == "direct-owned"
        # Get all outlets of the company (direct owned)
        Outlet.includes(:company).where(company_id: company).order("created_at asc")
      else
        # Get all outlets from 1 layer down. Get only outlets which franchisees has no franchise_licensee name, as it meant direct outlets. Should NOT get children's unit franchisee outlets
        company.children.includes(outlets: [:franchisee]).where(outlets: { franchisees: { franchise_licensee: ""}}).map(&:outlets).flatten
      end
    else
      # Add all outlets (direct-owned or sub franchised)
      Outlet.includes(:company).where(company_id: company).order("created_at asc") + company.children.includes(outlets: [:franchisee]).where(outlets: { franchisees: { franchise_licensee: ""}}).map(&:outlets).flatten
    end
  end
end
