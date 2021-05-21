class ContactPolicy < ApplicationPolicy
  def index?
    company_startup?
  end

  def create?
    # Check if company has pro plan. If not, restrict it from adding to fundraising board.
    check_contact_length?
  end

  def update?
    show?
  end

  def show?
    company_startup?
  end

  class Scope < Scope
    def resolve
      # Scope contacts from the user's company
      scope.where(searchable: true)
    end
  end

  private
  def company_startup?
    # Check if company is a startup before accessing the investor profile or the search page
    user.company.startup?
  end

  def check_contact_length?
    if user.company.basic?
      Contact.where(cloned_by: user.company).length < 5
    else
      true
    end
  end
end
