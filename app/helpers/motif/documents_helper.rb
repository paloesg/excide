module Motif::DocumentsHelper
  def get_folders(company)
    # Get documents that are related to franchisees but are link to parent company
    @franchisee = company.parent.franchisees.find_by(franchise_licensee: company.name) if company.parent.present?
    if @franchisee.present?
      @folders = policy_scope(Folder).roots + @franchisee.folders
    else
      @folders = policy_scope(Folder).roots
    end
  end
end
