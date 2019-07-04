class TemplatePolicy < ApplicationPolicy
  def index?
    user_admin?
  end

  def create?
    user_admin?
  end

  def new?
    create?
  end

  def update?
    user_admin?
  end

  def edit?
    update?
  end

  def create_section?
    create?
  end

  def destroy_section?
    user_admin?
  end

  class Scope < Scope
    def resolve
      if user.has_role?(:admin, user.company)
        # Scope templates from the user's company.
        scope.where(company: user.company)
      else
        raise Pundit::NotAuthorizedError, 'not allowed to view this action'
      end
    end
  end

  private
  def user_admin?
    user.has_role?(:admin, user.company)
  end
end