class BatchPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.company == record.company
  end

   def create?
    user.present?
  end

   def new?
    create?
  end

   def update?
    user.company == record.company or user.has_role? :admin
  end

   def edit?
    update?
  end

   def destroy?
    user.has_role? :admin
  end

   class Scope < Scope
    def resolve
      # Scope batch by user who created the batch
      if user.has_role? :admin
        scope.all
      else
        scope.where(company: user.company)
      end
    end
  end
end
