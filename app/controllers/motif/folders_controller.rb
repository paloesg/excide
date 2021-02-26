class Motif::FoldersController < FoldersController
  layout 'motif/application'

  def edit
    authorize @folder
  end

  def update
    authorize @folder
    respond_to do |format|
      if @folder.update(folder_params)
        format.html { redirect_to motif_documents_path, notice: "Folder has been updated successfully."}
        format.json { render json: @folder, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    authorize @folder
    @company = current_user.company
    @users = @company.users.includes(:permissions)
    @folders = policy_scope(Folder).children_of(@folder)
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    @documents = Document.where(folder: @folder)
    @documents = Kaminari.paginate_array(@documents).page(params[:page]).per(10)

    render "motif/documents/index"
  end

  def destroy
    authorize @folder
    @folder.destroy
    respond_to do |format|
      format.html { redirect_to motif_documents_path, notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end
