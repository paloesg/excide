class Motif::CompanyPolicy < CompanyPolicy
  def new?
    user.present?
  end

  def create?
    user.present?
  end
end
