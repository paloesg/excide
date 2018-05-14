class Conductor::ClientsController < ApplicationController
  layout 'dashboard/application'

  before_action :set_company
  before_action :set_client, only: [:show]

  def index
    @clients = Client.where(company: @company).order(:id)
  end

  def show
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    @client.company = @company
    @client.user = current_user
    respond_to do |format|
      if @client.save
        format.html { redirect_to conductor_clients_path, notice: 'Client successfully created!' }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_client
    @client = Client.find_by(id: params[:id], company: @company)
  end

  def set_company
    @company = current_user.company
  end

  def client_params
    params.require(:client).permit(:name, :identifier)
  end
end
