class FolderPolicy < ApplicationPolicy
  def show?
    can_view?
  end

  def update?
    can_write? or user.has_role?(:admin, record.company)
  end

  def update_tags?
    update?
  end

  class Scope < Scope
    def resolve
      scope.where(company: user.company)
    end
  end
end
