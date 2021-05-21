class Overture::RolePolicy < RolePolicy
  def index?

  end

  def create?
    check_investor_groups?
  end

  private
  def check_investor_groups?
    if user.company.basic?
      user.company.roles.where.not(name: ["admin", "member"]).length < 2
    else
      true
    end
  end
end
