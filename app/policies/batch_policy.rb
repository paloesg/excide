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
    user == record.user or user.has_role?(:admin, record.company)
  end

   def edit?
    update?
  end

   def destroy?
    user.has_role? :admin, record.company
  end

   class Scope < Scope
    def resolve
      if user.has_role?(:admin)
        #Scope batch by user admin with same company
        scope.where(company: user.company)
      else
        #Scope batch by user who created the batch
        scope.where(company: user.company, user: user)
      end
    end
  end
end
