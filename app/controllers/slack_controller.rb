class SlackController < ApplicationController
  before_action :authenticate_user!
  def callback
    response = Slack::Web::Client.new.oauth_access(
      client_id: ENV['SLACK_CLIENT_ID'],
      client_secret: ENV['SLACK_CLIENT_SECRET'],
      code: params[:code],
      redirect_uri: "http://localhost:3000/oauth/authorize"
    )
    Rails.logger.info response.inspect
    puts "RESPONSE DATA: #{response}"
    # Team.find_or_create_by(id: response.team_id).update(
    #   name: response.team_name,
    #   access_token: response.access_token, # encrypted using this
    # )
    redirect_to root_path, notice: 'Successfully connected'
  end
end