class CheckoutPolicy < Struct.new(:user, :checkout)
	def create?
		user_admin?
	end

	def success?
		user_admin?
	end

	def cancel?
		user_admin?
	end

	private
	def user_admin?
    user.has_role?(:admin, user.company) or user.has_role? :superadmin
  end 
end