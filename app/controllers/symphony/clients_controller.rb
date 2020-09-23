class Symphony::ClientsController < ClientsController
  before_action :require_symphony

  private
  
  # checks if the user's company has Symphony. Links to symphony_policy.rb
  def require_symphony
    authorize :symphony, :index?
  end
end