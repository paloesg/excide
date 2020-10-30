class Motif::OutletsController < ApplicationController
  layout 'motif/application'
  before_action :set_franchisee_and_outlet, except: :create

  def create
    if params[:franchisee_name].present?
      @franchisee = Franchisee.create(name: params[:franchisee_name], company: current_user.company)
    end
    @outlet = Outlet.new(outlet_params)
    @outlet.franchisee = @franchisee
    respond_to do |format|
      if @outlet.save
        format.html { redirect_to motif_franchisees_path, notice: 'Outlet was successfully created.' }
        format.json { render :show, status: :created, location: @outlet }
      else
        format.html { render :new }
        format.json { render json: @outlet.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    
  end

  def update
    @franchisee.contact_person_details = {
      first_name: params[:contact_first_name],
      last_name: params[:contact_last_name],
      position: params[:position],
      contact_mobile: params[:contact_mobile],
      email: params[:contact_email],
      capital_available_for_investment: params[:capital],
      your_franchise_experience: params[:your_franchise_experience],
      other_experience: params[:other_experience],
    }

    if @franchisee.update(franchisee_params)
      redirect_to edit_motif_franchisee_path(@franchisee), notice: 'Successfully updated franchisee profile'
    else
      redirect_to motif_root_path, alert: 'Updating franchisee profile has failed. Please contact admin for advise.'
    end
  end

  private

  def set_franchisee_and_outlet
    @franchisee = Franchisee.find(params[:franchisee_id])
    @outlet = Outlet.find(params[:id])
  end
  # Only allow a list of trusted parameters through.
  def outlet_params
    params.require(:outlet).permit(:name, :city, :country)
  end
end
