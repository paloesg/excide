class CompanyPolicy < ApplicationPolicy
  def show?
    user.has_role? :superadmin or user.has_role?(:admin, record)
  end

  def new?
    user.has_role? :superadmin
  end

  def create?
    new?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def subscription_plan?
    show?
  end

  def billing_and_invoice?
    show?
  end

  def integration?
    show?
  end

  def check_contact_length?
    if user.company.basic?
      Contact.where(cloned_by: user.company).length < 6
    else
      true
    end
  end
end
