class TaskPolicy < ApplicationPolicy
  def update?
    user.has_role? :superadmin
  end
end