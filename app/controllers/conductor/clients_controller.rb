class Conductor::ClientsController < ClientsController
  def index
    @clients = Client.where(company: @company).order(:id)
  end

  def show
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def update
    if params[:add_to_xero] == 'true'
      @xero = Xero.new(@client.company)
      contact_id = @xero.create_contact(client_params)
      @client.xero_contact_id = contact_id
    end
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
end