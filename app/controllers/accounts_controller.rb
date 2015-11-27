class AccountsController < ApplicationController
  before_action :set_user

  def new
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: 'User was successfully updated.'
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
