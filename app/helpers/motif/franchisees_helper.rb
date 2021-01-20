module Motif::FranchiseesHelper
  def get_franchisee
    Franchisee.find_by(franchise_licensee: current_user.company.name)
  end
end
