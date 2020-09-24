class Motif::FoldersController < FoldersController
  def show
    authorize @folder

    @folders = policy_scope(Folder).children_of(@folder)
    @documents = policy_scope(Document).where(folder: @folder)

    render "motif/documents/index"
  end
end
