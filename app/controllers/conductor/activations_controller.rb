class Conductor::ActivationsController < ApplicationController
  before_action :set_conductor_activation, only: [:show, :edit, :update, :destroy]

  # GET /conductor/activations
  # GET /conductor/activations.json
  def index
    @conductor_activations = Conductor::Activation.all
  end

  # GET /conductor/activations/1
  # GET /conductor/activations/1.json
  def show
  end

  # GET /conductor/activations/new
  def new
    @conductor_activation = Conductor::Activation.new
  end

  # GET /conductor/activations/1/edit
  def edit
  end

  # POST /conductor/activations
  # POST /conductor/activations.json
  def create
    @conductor_activation = Conductor::Activation.new(conductor_activation_params)

    respond_to do |format|
      if @conductor_activation.save
        format.html { redirect_to @conductor_activation, notice: 'Activation was successfully created.' }
        format.json { render :show, status: :created, location: @conductor_activation }
      else
        format.html { render :new }
        format.json { render json: @conductor_activation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conductor/activations/1
  # PATCH/PUT /conductor/activations/1.json
  def update
    respond_to do |format|
      if @conductor_activation.update(conductor_activation_params)
        format.html { redirect_to @conductor_activation, notice: 'Activation was successfully updated.' }
        format.json { render :show, status: :ok, location: @conductor_activation }
      else
        format.html { render :edit }
        format.json { render json: @conductor_activation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conductor/activations/1
  # DELETE /conductor/activations/1.json
  def destroy
    @conductor_activation.destroy
    respond_to do |format|
      format.html { redirect_to conductor_activations_url, notice: 'Activation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conductor_activation
      @conductor_activation = Conductor::Activation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def conductor_activation_params
      params.require(:conductor_activation).permit(:activation_type, :start_time, :end_time, :remarks, :location)
    end
end
