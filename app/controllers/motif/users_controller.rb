class Motif::UsersController < ApplicationController
  layout 'motif/application'

  include Motif::PermissionsHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles
  before_action :set_user, except: [:index, :new, :create]

  def index
    @roles = @company_roles
    if params[:outlet_id].present?
      @users = Outlet.find_by(id: params[:outlet_id]).users
    else
      @users = User.where(company: @company).order(:id).uniq
    end
    @user = User.new
  end

  def create
    # Adding members in individual outlet
    if params[:outlet_id].present?
      @outlet = @company.outlets.find(params[:outlet_id])
      # Choosing existing user
      if params[:user_id].present?
        @user = @company.users.find(params[:user_id])
      else
        # Create new user
        @user = User.create(email: params[:user][:email], first_name: params[:user][:first_name], last_name: params[:user][:last_name], company: @company)
      end
      @user.outlets << @outlet
      # Set active_outlet for new user
      @user.active_outlet = @outlet
    else
      @user = User.find_or_initialize_by(email: params[:user][:email])
      if @user.new_record?
        @role = @company.roles.find(params[:role])
        @user.first_name = params[:user][:first_name]
        @user.last_name = params[:user][:last_name]
        @user.company = @company
        # Set role when creating
        @user.roles << @role
      end
    end
    # By default, user's language is english
    @user.language = "en"
    respond_to do |format|
      if @user.save
        # Set permission for company's folders and documents if user is a franchisor of company
        set_default_permissions(@user) if @user.has_role?(:franchisor, @user.company)
        format.html { params[:outlet_id].present? ? (redirect_to motif_outlet_members_path(@outlet), notice: "Member has been added into this outlet") : (redirect_to motif_users_path, notice: 'Teammate was successfully added.')}
      else
        format.html { redirect_to motif_users_path }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if @user.update(user_params)
      redirect_to edit_motif_user_path(@user), notice: 'User successfully updated!'
    else
      render :edit
    end
  end

  # In motif, it is called user_type. The assumption is that for each user, there is only 1 user type
  def add_role
    # AJAX request to update user type from motif teammates
    @user = @company.users.find(params[:user_id])
    @role = @company.roles.find(params[:role_id])
    @old_role = @user.motif_roles(@company)
    # Delete old role if there is old roles
    @user.remove_role(@old_role.name, @company) if @old_role.present?
    # Save new role into user
    @user.roles << @role
    respond_to do |format|
      if @user.save
        format.json { render json: { link_to: motif_users_path, status: "ok" } }
      else
        format.html { redirect_to motif_users_path }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    redirect_back fallback_location: motif_users_path, notice: 'User was successfully deleted.'
  end

  # Change user's outlet for franchisee with multiple outlets
  def change_language
    if current_user.update(user_params)
      redirect_to motif_root_path, notice: "Successfully changed language."
    else
      redirect_to motif_root_path, error: 'Sorry, there was an error when trying to change language. Please try again later.'
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def set_company_roles
    @company_roles = Role.where(resource_id: @company.id, resource_type: "Company", name: ["franchisor", "franchisee_owner", "master_franchisee"])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :stripe_card_token, :stripe_customer_id, :language, :password, :password_confirmation, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :reminder_whatsapp, :task_sms, :task_email, :task_slack, :task_whatsapp, :batch_sms, :batch_email, :batch_slack, :batch_whatsapp], :role_ids => [], company_attributes:[:id, :name, :connect_xero, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]])
  end
end
