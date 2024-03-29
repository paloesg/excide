class Overture::Investors::DocumentsController < Overture::DocumentsController
  layout 'overture/application'
  include Overture::UsersHelper
  include Overture::PermissionsHelper

  after_action :verify_authorized

  def index
    authorize([:overture, :investors, Document])
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    # params[:company_id] came from investor's dataroom to indicate startup company that is interested in the investor
    @interested_startup_company = params[:company_id].present? ? Company.find_by(id: params[:company_id]) : @company
    # Show startup company's documents to investors if they have permission access
    @documents = Document.where(folder_id: nil, company: @interested_startup_company).order(created_at: :desc).includes(:permissions).where(permissions: {can_view: true, role_id: @user.roles.map(&:id)})
    @documents = Kaminari.paginate_array(@documents).page(params[:page]).per(10)
    @folders = Folder.roots.includes(:permissions).where(company: @interested_startup_company, permissions: { can_view: true, role_id: @user.roles.map(&:id)}).where.not(name: ["Resource Portal", "Shared Files"])
    @roles = Role.where(resource_id: @company.id, resource_type: "Company").where.not(name: ["admin", "member"])
    @users = get_users(@company)
    @topic = Topic.new

    # Filter search by current_user's roles and filter results by permissions (method in permission helper)
    @public_key = Algolia.generate_secured_api_key(ENV['ALGOLIASEARCH_API_KEY_SEARCH'], {filters: "#{get_algolia_filter_string.slice(0..-5)}"})
  end

  def shared_files
    @startup = Company.find(params[:company_id])
    @shared_folder = Folder.find_by(name: "Shared Files", company: @startup)
    @folders = @shared_folder.children.includes(:permissions).where(company: @startup, permissions: { can_view: true, role_id: @user.roles.map(&:id)}).where.not(name: ["Resource Portal", "Shared Files"])
    # Show startup company's documents to investors if they have permission access
    @documents = @shared_folder.documents.where(company: @startup).order(created_at: :desc).includes(:permissions).where(permissions: {can_view: true, role_id: @user.roles.map(&:id)})
    @topic = Topic.new
  end

  private

  def set_document
    @document = @company.documents.find(params[:id])
  end
end
