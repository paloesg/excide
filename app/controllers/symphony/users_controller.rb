class Symphony::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles, only: [:new, :create, :edit]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_company, :notification_settings, :update_notification]

  def index
    @users = User.where(company: @company).order(:id).includes(:roles)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.company = @company
    if @user.save
      redirect_to symphony_users_path, notice: 'User successfully created!'
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if @user.update(user_params)
      redirect_to symphony_users_path, notice: 'User successfully updated!'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to symphony_users_path, notice: 'User was successfully deleted.'
  end

  def change_company
    if @user.update(user_params)
      redirect_to symphony_root_path, notice: 'Company changed to ' + @user.company.name + '.'
    else
      redirect_to symphony_root_path, error: 'Sorry, there was an error when trying to switch company.'
    end
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
      render :additional_information
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_user
    @user = User.find_by(id: params[:id], company: @company)
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
    user.update_attributes(stripe_card_token: card_token, stripe_customer_id: customer.id)
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
