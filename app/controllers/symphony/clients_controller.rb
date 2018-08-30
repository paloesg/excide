class Symphony::ClientsController < ClientsController
  include Adapter

  def index
    @clients = Client.where(company: @company).order(:id)
    @xero = Xero.new(session[:xero_auth])

    @contacts = @xero.get_contacts
  end
end