class BusinessController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business, only: [:edit, :update]

  def edit
  end

  def update
    if @business.update(business_params)
      redirect_to business_projects_path, notice: 'Business was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_business
    @user = current_user
    @business = @user.business
  end

  def business_params
    params.require(:business).permit(:id, :name, :industry, :company_type)
  end
end