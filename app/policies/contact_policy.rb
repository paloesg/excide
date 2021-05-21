class ContactPolicy < ApplicationPolicy
  def index?
    company_startup?
  end

  def create?
    # Check if company has pro plan. If not, restrict it from adding to fundraising board.
    user.company.pro?
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
end
