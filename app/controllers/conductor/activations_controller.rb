class Conductor::ActivationsController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_clients
  before_action :set_activation, only: [:show, :edit, :update, :destroy]

  # GET /conductor/activations
  # GET /conductor/activations.json
  def index
    @activations = Activation.all
  end

  # GET /conductor/activations/1
  # GET /conductor/activations/1.json
  def show
  end

  # GET /conductor/activations/new
  def new
    @activation = Activation.new
  end

  # GET /conductor/activations/1/edit
  def edit
  end

  # POST /conductor/activations
  # POST /conductor/activations.json
  def create
    @activation = Activation.new(activation_params)
    @activation.company = @company

    respond_to do |format|
      if @activation.save
        format.html { redirect_to conductor_activations_path, notice: 'Activation was successfully created.' }
        format.json { render :show, status: :created, location: @activation }
      else
        format.html { render :new }
        format.json { render json: @activation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conductor/activations/1
  # PATCH/PUT /conductor/activations/1.json
  def update
    respond_to do |format|
      if @activation.update(activation_params)
        format.html { redirect_to conductor_activations_path, notice: 'Activation was successfully updated.' }
        format.json { render :show, status: :ok, location: @activation }
      else
        format.html { render :edit }
        format.json { render json: @activation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conductor/activations/1
  # DELETE /conductor/activations/1.json
  def destroy
    @activation.destroy
    respond_to do |format|
      format.html { redirect_to conductor_activations_url, notice: 'Activation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activation
      @activation = Activation.find(params[:id])
    end

    def set_company_and_clients
      @user = current_user
      @company = @user.company
      @clients = Client.where(company_id: @company.id)
    end

    def build_addresses
      if @activation.address.blank?
        @activation.address = @activation.address.build
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activation_params
      params.require(:activation).permit(:activation_type, :start_time, :end_time, :remarks, :location, :client_id, address_attributes: [:line_1, :line_2, :postal_code])
    end
end
