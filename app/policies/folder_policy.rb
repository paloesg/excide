class FolderPolicy < ApplicationPolicy
  def show?
    can_view?
  end

  class Scope < Scope
    def resolve
      scope.where(company: user.company)
    end
  end
end
