class XeroSessionsController < ApplicationController
  include Adapter
  after_action :verify_authorized, only: :connect_to_xero
  
  def connect_to_xero
    authorize :xero_session, :connect_to_xero?
    @xero_client = Xeroizer::PartnerApplication.new(
      ENV["XERO_CONSUMER_KEY"],
      ENV["XERO_CONSUMER_SECRET"],
      "| echo \"#{ENV["XERO_PRIVATE_KEY"]}\" ",
      :rate_limit_sleep => 2,
      before_request: ->(request) {
        request.headers.merge! "User-Agent" => ENV['XERO_CONSUMER_KEY']
      }
    )


    request_token = @xero_client.request_token(oauth_callback: ENV['ASSET_HOST'] + '/xero_callback_and_update')
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    
    redirect_to request_token.authorize_url
  end

  def xero_callback_and_update
    if params[:oauth_verifier].present?
      @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "| echo \"#{ENV["XERO_PRIVATE_KEY"]}\" ")

      @xero_client.authorize_from_request(session[:request_token], session[:request_secret], oauth_verifier: params[:oauth_verifier])
      current_user.company.update_attributes(expires_at: @xero_client.client.expires_at, access_key: @xero_client.access_token.token, access_secret: @xero_client.access_token.secret, session_handle: @xero_client.session_handle, xero_organisation_name: @xero_client.Organisation.first.name)
      session.delete(:request_token)
      session.delete(:request_secret)
      @xero_client.Contact.all.each do |contact|
        xc = XeroContact.find_or_initialize_by(contact_id: contact.contact_id)
        xc.update(name: contact.name, company: current_user.company)
      end
      templates = Template.where(company: current_user.company)
      flash[:notice] = "User signed in and connected to Xero. You are currently using the 30-days free trial Symphony Pro!"
      if templates.present?
        redirect_to symphony_root_path        
      else
        redirect_to new_symphony_template_path
      end
    else
      redirect_to root_path, alert: "Connection to Xero failed."
    end
  end

  def disconnect_from_xero
    current_user.company.update_attributes(expires_at: nil, access_key: nil, access_secret: nil, session_handle: nil, xero_organisation_name: nil)

    redirect_to edit_company_path, notice: "You have been disconnected from Xero."
  end

  def update_contacts_from_xero
    @xero_client = Xero.new(current_user.company)
    @xero_client.get_contacts.each do |contact|
      xc = XeroContact.find_or_initialize_by(contact_id: contact.contact_id)
      xc.update(name: contact.name, company: current_user.company)
    end
    redirect_to edit_company_path, notice: "Contacts have been updated from Xero."
  end
end
