class Symphony::ClientsController < ApplicationController
  include Adapter
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    @clients = Client.where(company: @company).order(:id)
    @xero = Xero.new(session)

    begin
      @contacts = @xero.get_contacts
    rescue Xeroizer::OAuth::TokenExpired
      redirect_to user_xero_omniauth_authorize_path
    end
  end

  private

  def set_company
    @company = current_user.company
  end
end