class SlackController < ApplicationController
  before_action :authenticate_user!
  
  def callback
    response = Slack::Web::Client.new.oauth_v2_access(
      client_id: ENV['SLACK_CLIENT_ID'],
      client_secret: ENV['SLACK_CLIENT_SECRET'],
      code: params[:code],
      redirect_uri: "https://45afdfda.ngrok.io/oauth/authorization"
    )
    Rails.logger.info response.inspect
    puts "RESPONSE DATA: #{response}"
    current_user.company.update(
      authorize_slack_code: response.access_token,
      slack_access_response: response
    )
    redirect_to root_path, notice: 'Successfully connected'
  end
end
