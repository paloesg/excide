module Motif::OutletsHelper
  def get_outlets(company)
    # Outlets that are directly under the entity
    @owned_outlets = Outlet.includes(:company).where(company_id: company).order("created_at asc")
    # For MF to manage
    @sub_franchised_outlets = Outlet.includes(:franchisee).where(franchisees: {franchise_licensee: company.name})
    # Combine all the workflows, regardless of blank and present
    @outlets = @owned_outlets + @sub_franchised_outlets
    return @outlets
  end
end
