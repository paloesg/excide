class ContactStatusPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # Scope contacts from the user's company
      scope.where(company: user.company)
    end
  end
end
