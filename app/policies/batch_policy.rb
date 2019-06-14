class BatchPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user == record.user
  end

   def create?
    user.present?
  end

   def new?
    create?
  end

   def update?
    user == record.user or user.has_role? :admin
  end

   def edit?
    update?
  end

   def destroy?
    user.has_role? :admin
  end

   class Scope < Scope
    def resolve
      # Scope invoices by user who created the batch
      if user.has_role? :admin
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
