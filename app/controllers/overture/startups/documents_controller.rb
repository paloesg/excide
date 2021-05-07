class Overture::Startups::DocumentsController < Overture::DocumentsController
  layout 'overture/application'
  include Overture::UsersHelper
  include Overture::PermissionsHelper

  before_action :set_document, only: [:update, :destroy, :change_versions]

  after_action :verify_authorized

  def index
    authorize([:overture, :startups, Document])
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    @documents = Document.where(folder_id: nil, company: @company).order(created_at: :desc).includes(:permissions).where(permissions: {can_view: true, role_id: @user.roles.map(&:id)})
    @documents = Kaminari.paginate_array(@documents).page(params[:page]).per(5)
    @folders = Folder.roots.includes(:permissions).where(company: @company, permissions: { can_view: true, role_id: @user.roles.map(&:id)}).where.not(name: ["Resource Portal", "Shared Files"])
    @roles = Role.where(resource_id: @company.id, resource_type: "Company").where.not(name: ["admin", "member"])
    @users = get_users(@company)
    @folder = Folder.new
    @permission = Permission.new

    # Initialize filter string
    filters_string = ""
    current_user.roles.each do |role|
      # Append the string with OR condition to check for those who has role permissions
      filters_string += "permissions.role_id:#{role.id} OR "
    end
    # Slice off the last OR in the string
    @public_key = Algolia.generate_secured_api_key(ENV['ALGOLIASEARCH_API_KEY_SEARCH'], {filters: "company.slug:#{current_user.company.slug} AND (" + filters_string.slice(0..-5) + ")" })
  end

  def create
    # multiple file upload from uppy
    if params[:successful_files].present?
      parsed_files = JSON.parse(params[:successful_files])
      # Upload multiple files and set versions & permissions for the upload
      MultipleUploadsJob.perform_later(@user, parsed_files, params[:document_type], params[:folder_id])
    end
    respond_to do |format|
      if params[:folder_id].present?
        # Redirect when generated documents inside folders
        format.html { redirect_to overture_folder_path(id: params[:folder_id]), notice: "File(s) successfully uploaded into folder."  }
        format.json { render json: @files.to_json }
      else
        format.html {
          redirect_to overture_startups_documents_path, notice: "Your files are being processed. Please refresh the page to view the uploaded files."
        }
      end
    end
  end

  def update
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
        format.html { redirect_back fallback_location: overture_startups_documents_path }
        format.json { render json: { link_to: overture_startups_documents_path, status: "ok" } }
      else
        format.html { redirect_back fallback_location: overture_startups_documents_path }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @document
    if @document.destroy
      respond_to do |format|
        format.html { redirect_back fallback_location: overture_startups_documents_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Document was successfully deleted.'
    end
  end

  def delete_version_attachment
    @blob = ActiveStorage::Blob.find_signed(params[:signed_id])
    @attachment = ActiveStorage::Attachment.find_by(blob_id: @blob.id)
    @attachment.purge
    redirect_back fallback_location: overture_startups_documents_path, notice: "Version successfully deleted."
  end

  def change_versions
    # Change version of documents from Version History button
    old_attachment = @document.versions.attachments.find_by(current_version: true)
    old_attachment.current_version = false
    new_attachment = ActiveStorage::Attachment.find_by(id: params[:attachment_id])
    new_attachment.current_version = true
    if old_attachment.save and new_attachment.save
      redirect_back fallback_location: overture_startups_documents_path, notice: "Version changed!"
    else
      redirect_back fallback_location: overture_startups_documents_path, alert: "There was an error when changing version of document. Please contact support."
    end
  end

  private

  def set_document
    @document = @company.documents.find(params[:id])
  end
end
