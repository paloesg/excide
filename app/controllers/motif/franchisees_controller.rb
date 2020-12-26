class Motif::FranchiseesController < ApplicationController
  layout 'motif/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_franchisee, only: [:show, :edit, :update]
  before_action :set_franchisee_by_id, only: [:outlets, :users, :agreements, :upload_agreements]

  def index
    # Only query franchisees which doesnt have company name as franchise licensee
    @franchisees = @company.franchisees
  end

  def edit
    
  end

  def update
    if @franchisee.update(franchisee_params)
      redirect_to edit_motif_franchisee_path, notice: "Franchisee profile has been updated."
    else
      render :edit
    end
  end

  def show
    # Check that franchisee's company has children and that it is a master franchisee (as this is the default role when creating one)
    @sub_franchisees = @franchisee.company.children.present? ? @franchisee.company.children.find_by(name: @franchisee.franchise_licensee).franchisees : []
  end

  def outlets
    @outlets = @franchisee.outlets
  end

  def users
    # Check if franchisee's company has children
    @users = @franchisee.company.children.present? ? @franchisee.company.children.find_by(name: @franchisee.franchise_licensee).users : @franchisee.outlets.map(&:users).flatten
  end

  def agreements
    @documents = Document.where(franchisee_id: @franchisee.id)
  end

  def upload_agreements
    if params[:successful_files].present?
      # Create a folder in doc repo to store all the uploaded files
      @folder = Folder.find_or_create_by(name: "Agreement documents - #{@franchisee.franchise_licensee}", company: @company)
      # Give permission access to the person that uploaded the folder
      Permission.find_or_create_by(user: current_user, can_write: true, can_download: true, can_view: true, permissible: @folder)
      @files = []
      parsed_files = JSON.parse(params[:successful_files])
      parsed_files.each do |file|
        @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, @folder.id).run
        document = @generate_document.document
        document.franchisee = @franchisee
        document.save
        # attach and convert method with the response key to create blob
        document.attach_and_convert_document(file['response']['key'])
        @files.append document
      end
    end
    respond_to do |format|
      format.html { redirect_to motif_franchisee_agreements_path(franchisee_id: @franchisee.id), notice: "File(s) successfully uploaded."  }
      format.json { render json: @files.to_json }
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_franchisee
    @franchisee = Franchisee.find(params[:id])
  end

  def set_franchisee_by_id
    # Get franchisee by franchisee ID
    @franchisee = @company.franchisees.find_by(id: params[:franchisee_id])
  end

  def franchisee_params
    params.require(:franchisee).permit(:commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value, :franchise_licensee, :registered_address, :license_type, :max_outlet, :min_outlet)
  end
  
  def build_addresses
    if @franchisee.address.blank?
      @franchisee.address = @franchisee.build_address
    end
  end
end
