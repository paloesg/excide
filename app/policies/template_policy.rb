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

  def workflow_template?
    user.company == record.company
  end

  class Scope < Scope
    def resolve
      # Scope templates from the user's company and general templates (company is nil)
      scope.where(company: [user.company, nil])
    end
  end

  private
  def user_admin?
    user.has_role?(:admin, user.company)
  end
end
