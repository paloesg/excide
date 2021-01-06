module Motif::UsersHelper
  def get_users(company)
    if company.children.present?
      # Add users from the franchise company & users from master franchisee's entity
      company.users.includes(:permissions) + company.children.map(&:users).flatten
    else
      company.users.includes(:permissions)
    end
  end
end
