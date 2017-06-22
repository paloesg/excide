class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def new
    @company = Company.new
    @company.user = current_user
    @company.build_address
  end

  def edit
  end

  # Technically not creating a new entry. Updates user account details and create new comapny when user is first created and redirected here.
  def create
    customer = Stripe::Customer.create(
      :email => current_user.email,
      :description => [current_user.first_name, current_user.last_name].join(' ').squeeze(' '),
      :source  => params[:stripeToken]
    )

    subscription = Stripe::Subscription.create(
      :customer => customer.id,
      :plan => "compliance-toolkit",
    )
    @user.make_payment
    @user.save

    if @user.update(user_params)
      SlackService.new.company_signup(@user, @user.company).deliver
      redirect_to dashboards_path, notice: 'Your account was successfully created.'
    else
      render :new, error: 'Please ensure that all fields are entered.'
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_account_path
  end

  def update
    if @user.update(user_params)
      redirect_to edit_account_path, notice: 'Your account was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:id, :first_name, :last_name, :contact_number, :agree_terms,
      company_attributes: [:name, :industry, :company_type, :image_url, :description, :ssic_code, :financial_year_end, address_attributes: [:line_1, :line_2, :postal_code]])
  end

  def company_params
    params.require(:company).permit(:id, :name, :industry, :company_type, :image_url, :description,
      address_attributes: [:line_1, :line_2, :postal_code]
    )
  end
end
