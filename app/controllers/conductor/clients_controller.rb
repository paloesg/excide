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
