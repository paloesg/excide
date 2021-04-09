class Motif::ContactStatusesController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!
  before_action :set_contact_status, only: [:update, :destroy]

  def index
    @contact_statuses = policy_scope(ContactStatus).order('position ASC')
    @contact = Contact.new
  end

  def update
    respond_to do |format|
      if @contact_status.update(contact_status_params)
        format.json { render json: @contact_status, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @contact_status.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @contact_status.destroy
      respond_to do |format|
        format.html { redirect_to motif_contact_statuses_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Column was successfully deleted.'
    end
  end

  private
  def set_contact_status
    @contact_status = ContactStatus.find(params[:id])
  end

  def contact_status_params
    params.require(:contact_status).permit(:name, :position, :company_id)
  end
end
