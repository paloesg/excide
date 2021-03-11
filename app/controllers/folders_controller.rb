class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: [:show, :edit, :update, :destroy, :update_tags]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /folders
  # GET /folders.json
  def index
    @folders = policy_scope(Folder)
  end

  # GET /folders/1
  # GET /folders/1.json
  def show
  end

  # GET /folders/new
  def new
    @folder = Folder.new
  end

  # GET /folders/1/edit
  def edit
  end

  # POST /folders
  # POST /folders.json
  def create
    @folder = Folder.new(folder_params)
    authorize @folder
    roles = Role.where(resource: current_user.company, name: ["admin", "member"])
    roles.each do |role|
      # Create permission for all users (admins or members) in the company
      @permission = Permission.create(permissible: @folder, role: role, can_write: true, can_download: true, can_view: true)
    end
    @folder.company = current_user.company
    @folder.user = current_user
    respond_to do |format|
      if @folder.save
        format.html { redirect_back fallback_location: root_path, notice: 'Folder was successfully created.' }
        format.json { render :show, status: :created, location: @folder }
      else
        format.html { render :new }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /folders/1
  # PATCH/PUT /folders/1.json
  def update
    authorize @folder
    respond_to do |format|
      if @folder.update(remarks: params[:folder][:remarks])
        format.json { render json: @folder, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /folders/1
  # DELETE /folders/1.json
  def destroy
    @folder.destroy
    respond_to do |format|
      format.html { redirect_to folders_url, notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def update_tags
    authorize @folder
    @tags = []
    params[:values].each{|key, tag| @tags << tag[:value]} unless params[:values].blank?
    current_user.company.tag(@folder, with: @tags, on: :tags)
    respond_to do |format|
      format.json { render json: current_user.company.owned_tags.pluck(:name), status: :ok }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def folder_params
      params.require(:folder).permit(:name, :remarks, :parent_id)
    end
end
