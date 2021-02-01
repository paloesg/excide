class Overture::DocumentsController < ApplicationController
  layout 'overture/application'
  include Overture::UsersHelper
  include Overture::PermissionsHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_document, only: [:update, :destroy]

  after_action :verify_authorized, except: :index

  def index
    @folder = Folder.new
    @folders = Folder.roots.includes(:permissions).where(permissions: { can_view: true, user_id: @user.id })
    @documents = Document.where(folder_id: nil).order(created_at: :desc).includes(:permissions).where(permissions: { can_view: true, user_id: @user.id })
    @users = get_users(@company)
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    @topic = Topic.new
    @roles = Role.where(resource_id: @company.id, resource_type: "Company").where.not(name: ["admin", "member"])
  end

  def create
    # multiple file upload from uppy
    if params[:successful_files].present?
      @files = []
      parsed_files.each do |file|
        @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, params[:folder_id]).run
        document = @generate_document.document
        authorize document
        # attach and convert method with the response key to create blob
        document.attach_and_convert_document(file['response']['key'])
        # attach the document as the 1st version (for version history)
        document.versions.attach(file['response']['signed_id'])
        @files.append document
      end
    end
    respond_to do |format|
      if params[:folder_id].present?
        # Redirect when generated documents inside folders
        format.html { redirect_to overture_folder_path(id: params[:folder_id]), notice: "File(s) successfully uploaded into folder."  }
        format.json { render json: @files.to_json }
      else
        format.html {
          redirect_to overture_documents_path, notice: "File was successfully uploaded"
        }
      end
    end
  end

  def update
    # puts "Update action: #{params[:document][:versions]}"
    authorize @document
    if params[:folder_id].present?
      @folder = @company.folders.find(params[:folder_id])
    # this is for version history update of overture documents
    elsif params[:document][:versions].present?
      # Attach versions to the documents
      @document.versions.attach(params[:document][:versions])
    end
    respond_to do |format|
      # check if update comes from drag and drop or from remarks. If folder_id is not present, then update remarks
      if (params[:folder_id].present? ? @document.update(folder_id: @folder.id) : @document.update(remarks: params[:document][:remarks]))
        format.json { render json: { link_to: overture_documents_path, status: "ok" } }
        format.html { redirect_to overture_documents_path }
      else
        format.html { redirect_to overture_documents_path }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @document
    if @document.destroy
      respond_to do |format|
        format.html { redirect_to overture_documents_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Document was successfully deleted.'
    end
  end

  def toggle
    @user = User.find(params[:id])
    @permission = @user.permissions.find_by(permissible_id: params[:permissible_id])
    if @permission.present?
      if params[:permissible_type] == "view"
        @permission.update(can_view: !@permission.can_view)
      else
        @permission.update(can_download: !@permission.can_download)
      end
    else
      set_flash "Error, please try again"
    end
  end

  def delete_version_attachment
    @blob = ActiveStorage::Blob.find_signed(params[:signed_id])
    @attachment = ActiveStorage::Attachment.find_by(blob_id: @blob.id)
    @attachment.purge
    redirect_to overture_documents_path, notice: "Version successfully deleted."
  end

  private
  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_document
    @document = @company.documents.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:filename, :remarks, :company_id, :date_signed, :date_uploaded, :file_url, :workflow_id, :document_template_id, :tag_list, :raw_file, converted_images: [], versions: [])
  end
end
