class Overture::DocumentsController < ApplicationController
  layout 'overture/application'
  include Overture::UsersHelper
  include Overture::PermissionsHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_document, only: [:update, :destroy, :change_versions]

  after_action :verify_authorized, except: :index

  def index
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    # For startup documents page from investor POV. Startups will see his own company (current_user company)
    @permissible_company = params[:company_id].present? ? Company.find_by(id: params[:company_id]) : @company
    # For investor, they can see documents where they have can_view permissions in their group. Whereas for startup, they can see if they have user permissions
    @documents = params[:company_id].present? ? Document.where(folder_id: nil, company: @permissible_company).order(created_at: :desc).includes(:permissions).where(permissions: { can_view: true, role_id: [@user.roles.map(&:id)]} ) : Document.where(folder_id: nil, company: @permissible_company).order(created_at: :desc).includes(:permissions).where(permissions: { can_view: true, role_id: @user.roles.map(&:id) })
    @folders = params[:company_id].present? ? Folder.roots.includes(:permissions).where(company: @permissible_company, permissions: { can_view: true, role_id: [@permissible_company.roles.map(&:id)]}) : Folder.roots.includes(:permissions).where(company: @permissible_company, permissions: { can_view: true, role_id: @user.roles.map(&:id) }).where.not(name: "Resource Portal")
    @roles = Role.where(resource_id: @company.id, resource_type: "Company").where.not(name: ["admin", "member"])
    @users = get_users(@company)
    # Show shared files for investor without being signed for their due diligence
    @startups = @user.roles.map(&:permissions).flatten.map(&:permissible).map(&:company).uniq if @company.investor?
    @folder = Folder.new
    @permission = Permission.new
    @topic = Topic.new
  end

  def create
    # multiple file upload from uppy
    if params[:successful_files].present?
      @files = []
      parsed_files = JSON.parse(params[:successful_files])
      parsed_files.each do |file|
        @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, params[:folder_id]).run
        document = @generate_document.document
        authorize document
        # attach and convert method with the response key to create blob
        document.attach_and_convert_document(file['response']['key'])
        # attach the document as the 1st version (for version history)
        document.versions.attach(file['response']['signed_id'])
        # Make the attachment the current (first) version
        document.versions.attachments.first.current_version = true
        document.versions.attachments.first.save
        @files.append document
        @admin_role = Role.find_by(resource: current_user.company, name: "admin")
        # Create document permissions for all admin users
        Permission.create(role: @admin_role, can_write: true, can_download: true, can_view: true, permissible: document)
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
      # Make the latest attachment the current version and remove prev attachment as the current version
      old_attachment = @document.versions.attachments.find_by(current_version: true)
      old_attachment.current_version = false
      new_attachment = @document.versions.attachments.order('created_at DESC').first
      new_attachment.current_version = true
      old_attachment.save
      new_attachment.save
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

  def change_versions
    # Change version of documents from Version History button
    old_attachment = @document.versions.attachments.find_by(current_version: true)
    old_attachment.current_version = false
    new_attachment = ActiveStorage::Attachment.find_by(id: params[:attachment_id])
    new_attachment.current_version = true
    if old_attachment.save and new_attachment.save
      redirect_to overture_documents_path, notice: "Version changed!"
    else
      redirect_to overture_root_path, alert: "There was an error when changing version of document. Please contact support."
    end
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
