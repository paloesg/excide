class Conductor::AllocationsController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_allocation, only: [:show, :edit, :update, :destroy]
  before_action :set_temp_staff, only: [:new, :edit]

  # GET /allocations
  # GET /allocations.json
  def index
    @allocations = Allocation.joins(:activation).where(activations: { company_id: @company.id })
    if params[:allocation].present?
      @users = User.with_role :temp_staff, @company
      @allocation = Allocation.find(params[:allocation])
    else
      @users = User.none
      @allocation = Allocation.none
    end
  end

  # GET /allocations/1
  # GET /allocations/1.json
  def show
  end

  # GET /allocations/new
  def new
    @allocation = Allocation.new
    @activations = Activation.where(company: @company)
  end

  # GET /allocations/1/edit
  def edit
  end

  # POST /allocations
  # POST /allocations.json
  def create
    @allocation = Allocation.new(allocation_params)

    respond_to do |format|
      if @allocation.save
        format.html { redirect_to conductor_allocations_path, notice: 'Allocation was successfully created.' }
        format.json { render :show, status: :created, location: @allocation }
      else
        format.html { render :new }
        format.json { render json: @allocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /allocations/1
  # PATCH/PUT /allocations/1.json
  def update
    respond_to do |format|
      if @allocation.update(allocation_params)
        format.html { redirect_to conductor_allocations_path, notice: 'Allocation was successfully updated.' }
        format.json { render :show, status: :ok, location: @allocation }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.html { render :edit }
        format.json { render json: @allocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allocations/1
  # DELETE /allocations/1.json
  def destroy
    @allocation.destroy
    respond_to do |format|
      format.html { redirect_to conductor_allocations_path, notice: 'Allocation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export
    @allocations = Allocation.joins(:activation).where(activations: { company_id: @company.id })
    send_data @allocations.to_csv, filename: "Allocations-#{Date.today}.csv"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_allocation
      @allocation = Allocation.find(params[:id])
    end

    def set_company
      @company = current_user.company
    end

    def set_temp_staff
      @users = User.where(company: @company).with_role :temp_staff, @company
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def allocation_params
      params.require(:allocation).permit(:user_id, :activation_id, :allocation_date, :start_time, :end_time)
    end
end
