class XeroSessionsController < ApplicationController

  def self.connect_xero_organisation(session)
    @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "xero-privatekey.pem")
    request_token = @xero_client.request_token(oauth_callback: "http://localhost:3000/xero_session_callback")
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    request_token.authorize_url
  end

  def xero_organisation_detail
    if params[:oauth_verifier].present? 
      @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "xero-privatekey.pem")
      # begin
      @xero_client.authorize_from_request(session[:request_token], session[:request_secret], oauth_verifier: params[:oauth_verifier])
      session[:xero_auth] = { access_token: @xero_client.access_token.token, access_secret: @xero_client.access_token.secret }
      session.delete(:request_token)
      session.delete(:request_secret)
      update_company_xero_session(@xero_client)
      redirect_to edit_company_path(@company, xero: 'xero'), notice: "Settings have been saved"
      # rescue Exception => e
      #   puts "EXCEPTION IS #{e}"   
      #   redirect_to symphony_root_path
      # end
    else
      @organisation_detail = @company.xero_organisation
      @xero_organisation_accounts_details = @company.xero_organisation_accounts
    end
  end

  def update_company_xero_session(xeroizer)
    company = current_user.company

    company.update_attributes(expires_at: xeroizer.client.expires_at, access_key: xeroizer.access_token.token, access_secret: xeroizer.access_token.secret, session_handle: xeroizer.session_handle)
  end

  private
  def get_xero_client
    @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "xero-privatekey.pem")
    # Add AccessToken if authorised previously.
    if session[:xero_auth]
      @xero_client.authorize_from_access(
        session[:xero_auth][:access_token],
        session[:xero_auth][:access_key] )
    end
  end
end