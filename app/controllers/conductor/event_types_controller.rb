class Conductor::EventTypesController < ApplicationController
  layout 'dashboard/application'
  before_action :set_user_and_company, only: [:show, :new, :edit, :create, :index]
  before_action :set_event_type, only: [:show, :edit, :update, :destroy]

  def index
    @event_types = EventType.all
  end

  def show
  end

  def new
    @event_type = EventType.new
  end

  def edit
  end

  def create
    @event_type = EventType.new(event_type_params)

    respond_to do |format|
      if @event_type.save
        format.html { redirect_to conductor_event_types_path, notice: 'Event type was successfully created.' }
        format.json { render :show, status: :created, location: @event_type }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.html { render :new }
        format.json { render json: @event_type.errors, status: :unprocessable_entity }
        format.js   { render js: @event_type.errors.to_json }
      end
    end
  end

  def update
    respond_to do |format|
      if @event_type.update(event_type_params)
        format.html { redirect_to conductor_event_types_path, notice: 'Event type was successfully updated.' }
        format.json { render :show, status: :ok, location: @event_type }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.html { render :edit }
        format.json { render json: @event_type.errors, status: :unprocessable_entity }
        format.js   { render js: @event_type.errors.to_json }
      end
    end
  end

  def destroy
    @event_type.destroy
    respond_to do |format|
      format.html { redirect_to conductor_event_types_url, notice: 'Event type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_event_type
    @event_type = EventType.find(params[:id])
  end

  def set_user_and_company
    @user = current_user
    @company = Company.find(@user.company.id)
  end

  def event_type_params
    params.require(:event_type).permit(:name, :colour)
  end
end
