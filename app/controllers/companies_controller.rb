class CompaniesController < ApplicationController
  layout "dashboard/application"

  before_action :authenticate_user!
  before_action :set_company, only: [:edit, :update, :name_reservation, :incorporation]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    @company.submit_details

    if @company.save
       render :edit
    end
  end

  def edit
    build_addresses
  end

  def update
    if @company.update(company_params)
      redirect_to edit_company_path, notice: 'Company was successfully updated.'
    else
      render :edit
    end
  end

  def name_reservation
  end

  def incorporation
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end

  def company_params
    params.require(:company).permit(:id, :name, :industry, :company_type, :image_url, :description, :ssic_code, :financial_year_end,
      address_attributes: [:line_1, :line_2, :postal_code]
    )
  end

  def build_addresses
    if @company.address.blank?
      @company.address = @company.address.build
    end
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end