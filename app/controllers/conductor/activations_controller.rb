class Conductor::ActivationsController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_clients
  before_action :set_event_owners, only: [:new, :edit]
  before_action :set_activation, only: [:show, :edit, :update, :destroy, :reset, :create_allocations]

  # GET /conductor/activations
  # GET /conductor/activations.json
  def index
    @date_from = params[:start_date].present? ? params[:start_date].to_date.beginning_of_month : Date.current.beginning_of_month
    @date_to = @date_from.end_of_month
    @activations = Activation.where(start_time: @date_from..@date_to)
    # Only show activations relevant to contractor if logged in as contractor
    @activations = @activations.joins(:allocations).where(allocations: { user_id: @user.id }) if @user.has_role? :contractor, :any
  end

  # GET /conductor/activations/1
  # GET /conductor/activations/1.json
  def show
  end

  # GET /conductor/activations/new
  def new
    @activation = Activation.new
    @activation.build_address
  end

  # GET /conductor/activations/1/edit
  def edit
    @activation.build_address if @activation.address.blank?
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
        set_event_owners
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
        set_event_owners
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

  def reset
    @activation.allocations.destroy_all
    respond_to do |format|
      format.html { redirect_to conductor_activations_url, notice: 'Activation was successfully reset.' }
      format.json { head :no_content }
    end
  end

  def create_allocations
    count = params[:count].to_i
    count.times do
      @allocation = Allocation.new(activation_id: @activation.id, allocation_date: @activation.start_time, start_time: @activation.start_time, end_time: @activation.end_time, allocation_type: params[:type].underscore)
      if !@allocation.save
        format.json { render json: @allocation.errors, status: :unprocessable_entity  }
      end
    end
    respond_to do |format|
      format.json { render json: @activation, status: :ok  }
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

    def set_event_owners
      @event_owners = User.where(company: @company).with_role :event_owner, @company
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activation_params
      params.require(:activation).permit(:activation_type, :start_time, :end_time, :remarks, :location, :client_id, :event_owner_id, address_attributes: [:line_1, :line_2, :postal_code])
    end
end
