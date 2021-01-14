module Overture::UsersHelper
  def get_users(company)
    if company.investors.present?
      # Add users from current company & users from investor company (Since investor cant share currently, it might not even be used)
      company.users.includes(:permissions) + company.startups.map(&:users).flatten
    elsif company.startups.present?
      company.users.includes(:permissions) + company.investors.map(&:users).flatten
    else
      company.users.includes(:permissions)
    end
  end
end
