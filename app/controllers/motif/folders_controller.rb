class Motif::FoldersController < FoldersController
  before_action :require_motif

  private

  # checks if the user's company has Motif. Links to motif_policy.rb
  def require_motif
    authorize :motif, :index?
  end
end