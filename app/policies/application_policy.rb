class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  # Use metaprogramming to define the methods of the different access types available.
  #
  # For access type of "view", this is what the method translates into:
  #
  # def can_view?
  #   has_permission = false

  #   record.permissions.where(role_id: user.roles).each do |permission|
  #     has_permission = permission.can_view?
  #     break if has_permission
  #   end

  #   return has_permission
  # end

  %w{write view download}.each do |method|
    define_method "can_#{method}?" do
      has_permission = false

      # Get the rows in permissions table that correspond to the current document or folder which also includes the roles that current user has.
      record.permissions.where(role_id: user.roles).each do |permission|
        has_permission = permission.send("can_#{method}?")
        break if has_permission
      end

      return has_permission
    end
  end
end
