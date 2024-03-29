class Symphony::UsersController < ApplicationController
  layout 'symphony/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles, only: [:new, :create, :edit]
  before_action :set_user, except: [:index, :new, :create, :edit_additional_information]

  def index
    @users = User.joins(:roles).where(:roles => {resource_id: @company.id}).order(:id).uniq
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])
    if @user.first_name.nil?
      @user.update(user_params)
      message = 'User successfully created!'
    else
      updated_roles = Role.where(id: params[:user][:role_ids])
      @user.roles << updated_roles
      message = 'User successfully added!'
    end
    @user.company = @company
    if @user.save
      redirect_to symphony_users_path, notice: message
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    # Get all the updated roles by finding the role instance
    updated_roles = Role.where(id: params[:user][:role_ids])
    # Remove all the roles in that company and then add in the new
    @user.roles.where(resource_id: current_user.company.id).each do |role|
      @user.remove_role(role.name, current_user.company)
    end
    # Append update roles to user's roles
    @user.roles << updated_roles
    if @user.update(first_name: params[:user][:first_name], last_name: params[:user][:last_name], email: params[:user][:email], contact_number: params[:user][:contact_number])
      redirect_to symphony_users_path, notice: 'User successfully updated!'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to symphony_users_path, notice: 'User was successfully deleted.'
  end

  def notification_settings
  end

  def update_notification
    if @user.update(user_params)
      redirect_to symphony_root_path, notice: 'Notification settings updated successfully!'
    else
      redirect_to notification_settings_symphony_user(@user), alert: 'Error updating notification settings.'
    end
  end

  def edit_additional_information
    @user = current_user
    if @user.update(user_params)
      # Free trial period ends after 30 days
      @user.company.trial_end_date = @user.company.created_at + 30.days
      @user.company.save
      # Only process payment when customer click to subscribe during sign up
      if !params[:user][:subscription_type].nil?
        process_payment(@user.id, @user.email, user_params[:stripe_card_token], params[:user][:subscription_type])
        flash[:notice] = 'Thank you for your subscription. Your payment has been successfully processed.'
      else
        flash[:notice] = 'Thank you for signing up. You are currently using the 30-day free trial of Symphony Pro.'
      end
      if @user.company.connect_xero
        redirect_to connect_to_xero_path
      else
        redirect_to new_symphony_template_path
      end
    else
      render 'users/registrations/additional_information', layout: 'application'
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def set_company_roles
    @company_roles = Role.where(resource_id: @company.id, resource_type: "Company")
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :stripe_card_token, :stripe_customer_id, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :reminder_whatsapp, :task_sms, :task_email, :task_slack, :task_whatsapp, :batch_sms, :batch_email, :batch_slack, :batch_whatsapp], :role_ids => [], company_attributes:[:id, :name, :connect_xero, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]])
  end

  def build_addresses
    if @company.address.blank?
      @company.address = @company.build_address
    end
  end

  def process_payment(user_id, email, card_token, subscription_type)
    customer = Stripe::Customer.create({email: email, card: card_token})
    # Create the plan based on what user clicked (monthly or annually)
    if subscription_type == 'monthly'
      Stripe::Subscription.create({
        customer: customer.id,
        items: [{plan: ENV['STRIPE_MONTHLY_PLAN']}],
      })
    elsif subscription_type == 'annual'
      Stripe::Subscription.create({
        customer: customer.id,
        items: [{plan: ENV['STRIPE_ANNUAL_PLAN']}],
      })
    end

    user = User.find(user_id)
    # update account stripe in user
    user.update(stripe_card_token: card_token, stripe_customer_id: customer.id)
    # upgrade company to pro immediately
    user.company.upgrade
    user.save

    # Do Charge
    # charge = Stripe::Charge.create({
    #   customer: user.stripe_customer_id.to_s,
    #   amount: 1000,
    #   currency: 'sgd',
    #   description: 'Charge for first member',
    # })
  end
end
