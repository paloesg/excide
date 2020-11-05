class Motif::FranchiseesController < ApplicationController
  layout 'motif/application'
  
  before_action :set_company, except: :index
  before_action :set_franchisee, except: :index

  def index
    @franchisees = Franchisee.all
    @outlets = Outlet.all
    @outlet = Outlet.new
  end

  def edit
    build_addresses
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

  def set_company
    @company = current_user.company
  end

  def set_franchisee
    @franchisee = Franchisee.find(params[:id])
  end

  def franchisee_params
    params.require(:franchisee).permit(:name, :website_url, :established_date, :annual_turnover_rate, :currency, :address, :description, :contact_person_details, :profile_picture, :contact,  address_attributes: [:line_1, :line_2, :postal_code, :city, :country, :state])
  end
  
  def build_addresses
    if @franchisee.address.blank?
      @franchisee.address = @franchisee.build_address
    end
  end
end
