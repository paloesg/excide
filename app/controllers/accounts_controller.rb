class AccountsController < ApplicationController
  before_action :set_user

  def new
  end

  def edit
  end

  # Technically not creating a new entry. Updates user account details when user is first created and redirected here.
  def create
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Your account was successfully created.'
    else
      render :new
    end
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
      params.require(:user).permit(:id, :first_name, :last_name, :contact_number, :allow_contact, :agree_terms)
    end

end
