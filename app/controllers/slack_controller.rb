class SlackController < ApplicationController
  before_action :authenticate_user!
  
  def callback
    response = Slack::Web::Client.new.oauth_v2_access(
      client_id: ENV['SLACK_CLIENT_ID'],
      client_secret: ENV['SLACK_CLIENT_SECRET'],
      code: params[:code],
      redirect_uri: ENV['ASSET_HOST'] + '/oauth/authorization'
    )
    Rails.logger.info response.inspect
    current_user.company.update(
      slack_access_response: response
    )
    redirect_to edit_company_path, notice: 'Successfully connected'
  end

  def disconnect_from_slack
    current_user.company.update_attributes(slack_access_response: nil)

    redirect_to edit_company_path, notice: "You have been disconnected from Slack."
  end
end
