class Conductor::ActivationTypesController < ApplicationController
  layout 'dashboard/application'
  before_action :set_user_and_company, only: [:show, :new, :edit, :create, :index]
  before_action :set_activation_type, only: [:show, :edit, :update, :destroy]

  def index
    @activation_types = ActivationType.all
  end

  def show
  end

  def new
    @activation_type = ActivationType.new
  end

  def edit
  end

  def create
    @activation_type = ActivationType.new(activation_type_params)

    respond_to do |format|
      if @activation_type.save
        format.html { redirect_to conductor_activation_types_path, notice: 'Activation type was successfully created.' }
        format.json { render :show, status: :created, location: @activation_type }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.html { render :new }
        format.json { render json: @activation_type.errors, status: :unprocessable_entity }
        format.js   { render js: @activation_type.errors.to_json }
      end
    end
  end

  def update
    respond_to do |format|
      if @activation_type.update(activation_type_params)
        format.html { redirect_to conductor_activation_types_path, notice: 'Activation type was successfully updated.' }
        format.json { render :show, status: :ok, location: @activation_type }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.html { render :edit }
        format.json { render json: @activation_type.errors, status: :unprocessable_entity }
        format.js   { render js: @activation_type.errors.to_json }
      end
    end
  end

  def destroy
    @activation_type.destroy
    respond_to do |format|
      format.html { redirect_to conductor_activation_types_url, notice: 'Activation type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_activation_type
    @activation_type = ActivationType.find(params[:id])
  end

  def set_user_and_company
    @user = current_user
    @company = Company.find(@user.company.id)
  end

  def activation_type_params
    params.require(:activation_type).permit(:name, :colour)
  end
end
