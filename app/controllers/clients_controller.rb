class ClientsController < ApplicationController
  include Adapter

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_client, only: [:show, :edit, :update, :destroy, :xero_create]

  rescue_from Xeroizer::OAuth::TokenExpired, Xeroizer::OAuth::TokenInvalid, with: :xero_login

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

    if params[:add_to_xero] == 'true'
      @xero = Xero.new(@client.company)
      contact_id = @xero.create_contact(client_params)
      @client.xero_contact_id = contact_id
    end

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

  def edit
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to conductor_clients_path, notice: 'Client successfully updated!.' }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @client.destroy
    redirect_to conductor_clients_path, notice: 'Client was successfully deleted.'
  end

  def xero_create
    @xero = Xero.new(@client.company)
    contact_id = @xero.create_contact(name: @client.name)
    @client.xero_contact_id = contact_id

    respond_to do |format|
      if @client.save
        format.html { redirect_to session[:previous_url], notice: 'Client successfully added to Xero!' }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def xero_login
    redirect_to connect_to_xero_path(xero_connects_from: {
      client: 'client',
      workflow_id: params[:workflow_id]
    })
  end

  def set_client
    @client = Client.find_by(id: params[:id], company: @company)
  end

  def client_params
    params.require(:client).permit(:name, :identifier, :xero_contact_id)
  end
end
