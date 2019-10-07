class XeroSessionsController < ApplicationController

  def self.connect_to_xero(session)
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
    request_token.authorize_url
  end

  def xero_callback_and_update
    if params[:oauth_verifier].present?
      @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "| echo \"#{ENV["XERO_PRIVATE_KEY"]}\" ")
      company = current_user.company
      # begin
      @xero_client.authorize_from_request(session[:request_token], session[:request_secret], oauth_verifier: params[:oauth_verifier])
      company.update_attributes(expires_at: @xero_client.client.expires_at, access_key: @xero_client.access_token.token, access_secret: @xero_client.access_token.secret, session_handle: @xero_client.session_handle, xero_organisation_name: @xero_client.Organisation.first.name)
      session.delete(:request_token)
      session.delete(:request_secret)
      @xero_client.Contact.all.map{|c| XeroContact.create(name: c.name, contact_id: c.contact_id, company: company)}
      redirect_to symphony_root_path, notice: "User signed in and connected to Xero."

      #redirect the page after sign in depending on the role of the user
      # if current_user.has_role? :superadmin
      #   redirect_to admin_root_path, notice: "User signed in and Xero settings have been saved"
      # elsif current_user.has_role? :associate, :any
      #   redirect_to conductor_user_path(current_user), notice: "User signed in and Xero settings have been saved"
      # elsif current_user.has_role? :shared_service, :any
      #   redirect_to symphony_batches_path, notice: "User signed in and Xero settings have been saved"
      # elsif current_user.company.present?
      #   redirect_to symphony_root_path, notice: "User signed in and Xero settings have been saved"
      # else
      #   session[:previous_url] || root_path
      # end
    else
      redirect_to root_path, alert: "Connection to Xero failed."
    end
  end
end
