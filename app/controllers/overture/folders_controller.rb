class Overture::FoldersController < FoldersController
  layout 'overture/application'

  before_action :set_company

  def edit
    authorize @folder
  end

  def update
    authorize @folder
    respond_to do |format|
      if @folder.update(folder_params)
        format.html { redirect_to overture_startups_documents_path, notice: "Folder has been updated successfully."}
        format.json { render json: @folder, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    authorize @folder
    @users = @company.users.includes(:permissions)
    @folders = Folder.children_of(@folder)
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    @documents = Document.where(folder: @folder)
    @roles = Role.where(resource_id: @company.id, resource_type: "Company").where.not(name: ["admin", "member"])
    @topic = Topic.new
    @permission = Permission.new
    @new_folder = Folder.new

    @company.startup? ? (render "overture/startups/documents/index") : (render "overture/investors/documents/index")
  end

  def destroy
    authorize @folder
    @folder.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: overture_root_path, notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def toggle
    @user = User.find(params[:id])
    @permission = @user.permissions.find_by(permissible_id: params[:permissible_id])
    if @permission != nil?
      if params[:permissible_type] == "view"
        @permission.update(can_view: params[:permission])
      else
        @permission.update(can_download: params[:permission])
      end
    else
      set_flash "Error, please try again"
    end
  end

  private
  def set_company
    @user = current_user
    @company = @user.company
  end
end
