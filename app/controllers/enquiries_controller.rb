class EnquiriesController < ApplicationController
  def index
    @enquiry = Enquiry.new
  end

  def create
    @enquiry = Enquiry.new(enquiry_params)

    respond_to do |format|
      if @enquiry.save
        SlackService.new.new_enquiry(@enquiry).deliver
        format.json { render json: 1, status: :created, location: @enquiry }
      else
        format.json { render json: @enquiry.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def enquiry_params
    params.permit(:name, :contact, :email, :comments, :source)
  end
end
