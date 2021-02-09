class Overture::DocumentsController < ApplicationController
  layout 'overture/application'
  include Overture::UsersHelper
  include Overture::PermissionsHelper

  before_action :authenticate_user!
  before_action :set_company

  private
  def set_company
    @user = current_user
    @company = @user.company
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:filename, :remarks, :company_id, :date_signed, :date_uploaded, :file_url, :workflow_id, :document_template_id, :tag_list, :raw_file, converted_images: [], versions: [])
  end
end
