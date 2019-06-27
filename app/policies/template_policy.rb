class TemplatePolicy < ApplicationPolicy
  def index?
    user_admin?
  end

  def create?
    user_admin?
  end

  def new?
    user_admin?
  end

  def update?
    user_admin?
  end

  def edit?
    user_admin?
  end

  def create_section?
    user_admin?
  end

  def destroy_section?
    user_admin?
  end

  class Scope < Scope
    def resolve
      # Scope templates from the user's company.
      scope.where(company: user.company)
    end
  end

  private
  def user_admin?
    user.has_role?(:admin, user.company)
  end
end