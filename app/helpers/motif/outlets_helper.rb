module Motif::OutletsHelper
  def get_outlets_by_type(type, company)
    if type.present?
      if type == "direct-owned"
        # Get all outlets of the company (direct owned)
        Outlet.includes(:company, :franchisee).where(company_id: company)
      else
        # Get children's direct-owned outlets (where franchise_licensee is empty). The second part of the equation gets company's own unit_franchisee & sub_franchisee as these are not a company entity, hence we could not call company.children.
        # Should NOT get children's unit franchisee outlets
        company.children.includes(outlets: [:franchisee]).where(outlets: { franchisees: { franchisee_company: [company.children]}}).map(&:outlets).flatten
      end
    else
      # Add all outlets (direct-owned or sub franchised)
      Outlet.includes(:company).where(company_id: company).order("created_at asc") + company.children.includes(outlets: [:franchisee]).where(outlets: { franchisees: { franchisee_company: [company.children]}}).map(&:outlets).flatten
    end
  end

  def get_outlets_that_has_no_workflows(template_type, company)
    # Check if workflow of a particular template_type exists
    workflows = Workflow.includes(:template).where(company: company, templates: { template_type: template_type })
    # This checks for parent workflows, as direct owned outlet for franchisee is usually created by parent company (for eg, franchisor onboards for it's franchisee). We will need to exclude these workflow's outlets so that it would not appear in the franchisee's dropdown
    parent_workflows = Workflow.includes(:template).where(company: company.parent, templates: { template_type: template_type })
    # If workflow of that template_type exists, then we will exclude outlets in the dropdown when creating workflows using the array method excluding given in Rails 6
    if workflows.present?
      (company.outlets + company.children.includes(outlets: [:franchisee]).where(outlets: { franchisees: { franchisee_company: [company.children]}}).map(&:outlets).flatten).excluding(workflows.map(&:outlet))
    else
      (company.outlets + company.children.includes(outlets: [:franchisee]).where(outlets: { franchisees: { franchisee_company: [company.children]}}).map(&:outlets).flatten).excluding(parent_workflows.map(&:outlet))
    end
  end
end
