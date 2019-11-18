class HomeController < ApplicationController
  layout 'stack/application'

  def index
    @enquiry = Enquiry.new
  end

  def robots
    robots = File.read(Rails.root + "config/robots.#{ENV['APP_NAME']}.txt")
    render plain: robots
  end
end
