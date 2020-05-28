class XeroSessionsController < ApplicationController
  include Adapter
  after_action :verify_authorized, except: :xero_callback_and_update

  def connect_to_xero
    authorize :xero_session, :connect_to_xero?
    @xero = Xero.new(current_user.company)
    request_token = @xero.request_token()
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def xero_callback_and_update
    if params[:oauth_verifier].present?
      @xero_client = Xero.new(current_user.company)

      # authorize requests
      @xero_client.authorize_from_request(session[:request_token], session[:request_secret], params[:oauth_verifier])
      # Update company with xero's oauth properties
      @xero_client.update_company_after_connecting_to_xero(current_user.company)
      session.delete(:request_token)
      session.delete(:request_secret)
      # Save xero contacts to database
      @xero_client.save_xero_contacts(current_user.company)
      # Save xero lineitems to database
      @xero_client.save_xero_line_items(current_user.company)
      templates = Template.where(company: current_user.company)
      if params[:invoice_type].present? and templates.present?
        flash[:notice] = "User is connected to Xero."
        redirect_to new_symphony_invoice_path(workflow_name: Workflow.find_by(id: params[:workflow_id]).template.slug, workflow_id: params[:workflow_id], workflow_action_id: params[:workflow_action_id], invoice_type: params[:invoice_type])
      elsif templates.present?
        redirect_to edit_company_path, notice: "User signed in and connected to Xero."
      else
        redirect_to new_symphony_template_path, notice: "User signed in and connected to Xero."
      end
    else
      redirect_to symphony_root_path, alert: "Connection to Xero failed."
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

  def update_tracking_categories_from_xero
    authorize :xero_session, :update_tracking_categories_from_xero?
    @xero_client = Xero.new(current_user.company)
    @xero_client.get_tracking_options.each do |tracking|
      @tc = XeroTrackingCategory.find_or_initialize_by(tracking_category_id: tracking.tracking_category_id)
      @tc.update(name: tracking.name, status: tracking.status, options: tracking.options, company: current_user.company)
    end
    redirect_to edit_company_path, notice: "Tracking categories have been updated from Xero."
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
end
