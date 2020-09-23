class SymphonyPolicy < Struct.new(:user, :symphony)
  def index?
    user.company.products.include? 'symphony'
  end
end