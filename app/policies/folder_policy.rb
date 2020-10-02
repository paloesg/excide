class FolderPolicy < ApplicationPolicy
  def show?
    can_view?
  end

  def update_tags?
    user.company == record.company
  end

  class Scope < Scope
    def resolve
      scope.where(company: user.company)
    end
  end
end
