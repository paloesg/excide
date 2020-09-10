class FolderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(company: user.company)
    end
  end
end
