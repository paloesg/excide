class Overture::Investors::DocumentsController < Overture::DocumentsController
  layout 'overture/application'
  include Overture::UsersHelper
  include Overture::PermissionsHelper

  after_action :verify_authorized, except: :index

  def index
    @startup_id = params[:company_id]
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    # For investor, it finds the company by getting from the url. Startup will get their own company
    @permissible_company = params[:company_id].present? ? Company.find_by(id: params[:company_id]) : @company
    # For investor, they can see documents where they have can_view (or higher) permissions in their group. Whereas for startup, they can see if they have role permissions
    @documents = Document.where(folder_id: nil, company: @permissible_company).order(created_at: :desc).includes(:permissions).where(permissions: {can_view: true, role_id: @user.roles.map(&:id)})
    @folders = Folder.roots.includes(:permissions).where(company: @permissible_company, permissions: { can_view: true, role_id: @user.roles.map(&:id)}).where.not(name: ["Resource Portal", "Shared Drive"])
    @roles = Role.where(resource_id: @company.id, resource_type: "Company").where.not(name: ["admin", "member"])
    @users = get_users(@company)
    # Show shared files for investor without being signed for their due diligence
    @startups = @user.roles.map(&:permissions).flatten.map(&:permissible).map(&:company).uniq if @company.investor?
    @topic = Topic.new
  end

  private

  def set_document
    @document = @company.documents.find(params[:id])
  end
end