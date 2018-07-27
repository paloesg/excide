class Conductor::ActivationTypesController < ApplicationController
  layout 'dashboard/application'
  before_action :set_user_and_company, only: [:new, :create, :index]

  def index
    @activation_types = ActivationType.all
  end

  def new
    @activation_type = ActivationType.new
  end

  def create
    @activation_type = ActivationType.new(activation_type_params)

    respond_to do |format|
      if @activation_type.save
        format.html { redirect_to conductor_activation_types_path, notice: 'Activation was successfully created.' }
        format.json { render :show, status: :created, location: @activation_type }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.html { render :new }
        format.json { render json: @activation_type.errors, status: :unprocessable_entity }
        format.js   { render js: @activation_type.errors.to_json }
      end
    end
  end

  def set_user_and_company
    @user = current_user
    @company = Company.find(@user.company)
  end

  def activation_type_params
    params.require(:activation_type).permit(:name, :slug, :colour)
  end
end
