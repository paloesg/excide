class MotifPolicy < Struct.new(:user, :motif)
  def index?
    user.company.products.include? 'motif'
  end
end