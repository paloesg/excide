class Conductor::AllocationsController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_allocation, only: [:show, :edit, :update, :destroy]
  before_action :set_contractor, only: [:new, :edit]
  before_action :set_activations, only: [:new, :edit]

  # GET /allocations
  # GET /allocations.json
  def index
    @allocations = Allocation.joins(:activation).where(activations: { company_id: @company.id }).order(allocation_date: :desc, start_time: :asc, id: :asc)
    if params[:allocation].present?
      @allocation = Allocation.find(params[:allocation])
      # Check if the availability date and allocation date matches first, then check whether the availability start time is less than the allocation start time, then finally check whether the availability end time is greater than the allocation end time. If all conditions are met, the user is available for assignment.
      @users = User.with_role(:contractor, @company).joins(:availabilities).where(availabilities: {available_date: @allocation.allocation_date}).where("availabilities.start_time <= ?", @allocation.start_time).where("availabilities.end_time >= ?", @allocation.end_time)
    else
      @allocation = Allocation.none
      @users = User.none
    end
  end

  # GET /allocations/1
  # GET /allocations/1.json
  def show
  end

  # GET /allocations/new
  def new
    @allocation = Allocation.new
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
        set_contractor
        set_activations
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
        set_contractor
        set_activations
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

    def set_contractor
      @users = User.where(company: @company).with_role :contractor, @company
    end

    def set_activations
      @activations = Activation.where(company: @company)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def allocation_params
      params.require(:allocation).permit(:user_id, :activation_id, :allocation_date, :start_time, :end_time)
    end
end
