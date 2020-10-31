class Motif::FoldersController < FoldersController
  layout 'motif/application'
  
  def show
    authorize @folder
    @company = current_user.company
    @roles = @company.roles.includes(:permissions)
    @folders = policy_scope(Folder).children_of(@folder)
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    @documents = policy_scope(Document).where(folder: @folder)

    render "motif/documents/index"
  end
end
