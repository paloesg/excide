class XeroSessionsController < ApplicationController
  include Adapter
  after_action :verify_authorized, except: :xero_callback_and_update
  
  def connect_to_xero
    authorize :xero_session, :connect_to_xero?
    @xero = Xero.new(current_user.company)
    request_token = @xero.request_token(current_user.company)
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
      @xero_client.Item.all.each do |item|
        xli = XeroLineItem.find_or_initialize_by(item_code: item.code)
        xli.update(description: item.description, quantity: item.quantity_on_hand, price: item.sales_details.unit_price, account: item.sales_details.account_code, tax: item.sales_details.tax_type, company: current_user.company)
      end
      templates = Template.where(company: current_user.company)
      flash[:notice] = "User signed in and connected to Xero."
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
    authorize :xero_session, :disconnect_from_xero?
    current_user.company.update_attributes(expires_at: nil, access_key: nil, access_secret: nil, session_handle: nil, xero_organisation_name: nil)

    redirect_to edit_company_path, notice: "You have been disconnected from Xero."
  end

  def update_contacts_from_xero
    authorize :xero_session, :update_contacts_from_xero?
    @xero_client = Xero.new(current_user.company)
    @xero_client.get_contacts.each do |contact|
      xc = XeroContact.find_or_initialize_by(contact_id: contact.contact_id)
      xc.update(name: contact.name, company: current_user.company)
    end
    redirect_to edit_company_path, notice: "Contacts have been updated from Xero."
  end

  def update_line_items_from_xero
    authorize :xero_session, :update_line_items_from_xero?
    @xero_client = Xero.new(current_user.company)
    @xero_client.get_items.each do |item|
      xli = XeroLineItem.find_or_initialize_by(item_code: item.code)
      xli.update(description: item.description, quantity: item.quantity_on_hand, price: item.sales_details.unit_price, account: item.sales_details.account_code, tax: item.sales_details.tax_type, company: current_user.company)
    end
    redirect_to edit_company_path, notice: "Line Items have been updated from Xero."
  end

  private
  def connect
    
  end
end
