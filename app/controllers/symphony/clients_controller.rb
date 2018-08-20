class Symphony::ClientsController < ClientsController
  include Adapter

  def index
    @clients = Client.where(company: @company).order(:id)
    @xero = Xero.new(session)

    begin
      @contacts = @xero.get_contacts
    rescue Xeroizer::OAuth::TokenExpired
      redirect_to user_xero_omniauth_authorize_path
    end
  end
end