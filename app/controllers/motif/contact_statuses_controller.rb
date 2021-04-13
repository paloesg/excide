class Motif::ContactStatusesController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!
  before_action :set_company, only: :create
  before_action :set_contact_status, only: [:update, :destroy]

  def index
    @contact_statuses = policy_scope(ContactStatus).order('position ASC')
    @contact = Contact.new
  end

  def create
    @contact_status = ContactStatus.new(contact_status_params)
    @contact_status.position = ContactStatus.where(company: @company).order(position: :asc).last.position + 1
    @contact_status.company = @company
    respond_to do |format|
      if @contact_status.save
        format.html { redirect_to motif_contact_statuses_path, notice: 'Status created successfully!' }
        format.json { render json: @contact_status, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @contact_status.errors, status: :unprocessable_entity }
      end
    end
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

  def set_company
    @company = current_user.company
  end

  def contact_status_params
    params.require(:contact_status).permit(:name, :position, :company_id, :colour)
  end
end
