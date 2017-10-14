class TaskPolicy < ApplicationPolicy
  def update?
    user.has_role? :admin
  end
end