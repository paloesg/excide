class BusinessController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business, only: [:edit, :update]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  def new
    @business = Business.new
  end

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
    params.require(:business).permit(:id, :name, :industry, :company_type, :image_url, :description)
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end