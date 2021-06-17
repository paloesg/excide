class CompaniesController < ApplicationController
  layout 'symphony/application'
  before_action :authenticate_user!
  before_action :set_company, only: [:show, :edit, :update, :billing, :integration]

  after_action :verify_authorized

  def show
    authorize @company
    @address = @company&.address
    @users = User.where(company: @company).order(:id).includes(:roles)
  end

  def new
    @company = Company.new
    authorize @company
  end

  def create
    @company = Company.new(company_params)
    authorize @company
    # Save the new company's product(s)
    @company.products = params[:products]
    # New company in overture should have basic (seedling) plan
    @company.account_type = "basic" if params[:products].include? "overture"
    if @company.save
      set_company_roles
      if @company.products.include? "motif"
        set_default_folders
        set_default_templates
      elsif @company.products.include? "overture"
        set_default_profile_or_contact
        set_default_contact_statuses
        set_default_overture_folders
      end
      current_user.update(company: @company)
      # Send Slack Notification when new company is created
      SlackService.new.company_signup(current_user.company).deliver
      # Redirect based on the products that was added to the company
      if @company.products.length > 1
        redirect_to root_path
      else
        # redirect to the root path of a single product
        redirect_to "/#{@company.products[0]}"
      end
    end
  end

  def edit
    authorize @company
    build_addresses
  end

  def update
    authorize @company
    # Store old roles
    @old_roles = { consultant: @company.consultant, associate: @company.associate, shared_service: @company.shared_service }

    if @company.update(company_params)
      # Remove all company roles except admin before updating company in case company roles have changed.
      remove_company_roles
      set_company_roles
      redirect_to edit_company_path, notice: 'Company was successfully updated.'
    else
      render :edit
    end
  end

  def billing
    authorize @company
  end

  def integration
    authorize @company
  end

  private

  def set_company_roles
    # Set company admin role only if old roles is not defined i.e. creating new company
    current_user.add_role(:admin, @company) unless defined?(@old_roles)
    # If company's product includes Motif, add motif roles to company
    if @company.products.include? "motif"
      @motif_default_roles = ['franchisor', 'franchisee_owner', 'master_franchisee']
      @motif_default_roles.each do |role_name|
        Role.create(name: role_name, resource: @company)
      end
    elsif @company.products.include? "overture"
      # For overture, add member and admin role
      Role.create(name: "member", resource: @company)
    end

    @company.consultant.add_role(:consultant, @company) if @company.consultant.present?
    @company.associate.add_role(:associate, @company) if @company.associate.present?
    @company.shared_service.add_role(:shared_service, @company) if @company.shared_service.present?
  end

  def set_default_folders
    # Create default folders with permissions when creating a franchise
    motif_default_folder_names = ["Financial", "Legal & Policy", "Social Media/App", "Media Repository (Training Videos & Materials)", "Operational", "Dialogue & Discussions", "Manuals & SOPs"]
    # Get all the new folder instances
    motif_default_folders = motif_default_folder_names.map{|name| Folder.create(name: name, company: @company)}
    # Current user should have access permission to default folders
    motif_default_folders.each do |folder|
      # Create full access permission for franchisor
      Permission.create(user_id: current_user.id, permissible: folder, can_write: true, can_view: true, can_download: true)
    end
  end

  def set_default_overture_folders
    # Create default folders with permissions when adding a new company
    overture_default_folder_names = ["Resource Portal", "Shared Files"]
    # Get all the new folder instances
    overture_default_folders = overture_default_folder_names.map{|name| Folder.create(name: name, company: @company)}
    # Give permission of default folders to admin and member of the company
    roles = Role.where(resource_id: @company.id, resource_type: "Company").where(name: ["admin", "member"])
    overture_default_folders.each do |folder|
      roles.each do |r|
        # Create full access permission for company created
        Permission.create(role_id: r.id, permissible: folder, can_write: true, can_view: true, can_download: true)
      end
    end
  end

  def set_default_templates
    motif_general_templates = Template.where(company_id: nil).where.not(template_type: nil)
    # Check if company products include Motif and that the motif general templates are present
    if motif_general_templates.present?
      motif_general_templates.each do |template|
        cloned_template = template.deep_clone include: { sections: :tasks }
        cloned_template.title = "#{template.title} - #{@company.name}"
        cloned_template.company = @company
        # Set template_pattern based on motif template_type, which will then set recurring attributes
        cloned_template.set_recurring_based_on_template_type
        cloned_template.save
      end
    end
  end

  def set_default_profile_or_contact
    if @company.investor?
      # Create a public contact for investor so that it can be searched by startups
      Contact.create(company_name: @company.name, created_by_id: current_user.id, company_id: @company.id, searchable: true)
    else
      # Create a profile instance for startup
      Profile.create(company: @company, name: @company.name)
    end
  end

  def set_default_contact_statuses
    if @company.startup?
      default_statuses = [["No Status", "#FFFFFF"], ["Contacted", "#c1ebf7"], ["In Discussion", "#ffd3b3"], ["Due Dilligence", "#f7f2b2"], ["Said Yes", "#edfab1"], ["Said No", "#fab1b1"]]
      default_statuses.each_with_index do |status, index|
        ContactStatus.create(name: status[0], startup: @company, position: index + 1, colour: status[1])
      end
    end
  end

  def remove_company_roles
    @old_roles[:consultant]&.remove_role(:consultant, @company)
    @old_roles[:associate]&.remove_role(:associate, @company)
    @old_roles[:shared_service]&.remove_role(:shared_service, @company)
  end

  def company_params
    params.require(:company).permit(:id, :name, :uen, :contact_details, :financial_year_end, :gst_quarter, :agm_date, :ar_date, :eci_date, :form_cs_date, :project_start_date, :consultant_id, :associate_id, :shared_service_id, :designated_working_time, :xero_email, :connect_xero, :account_type, :stripe_subscription_plan_data, :trial_end_date, :slack_access_response, :before_deadline_reminder_days, :website_url, :company_logo, :profile_logo, :banner_image, :company_bio, :company_type, address_attributes: [:line_1, :line_2, :postal_code, :city, :country, :state]
    )
  end

  def build_addresses
    if @company.address.blank?
      @company.address = @company.build_address
    end
  end
end
