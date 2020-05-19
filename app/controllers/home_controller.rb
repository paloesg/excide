class HomeController < ApplicationController
	layout 'metronic/application'
  def index
    @enquiry = Enquiry.new
  end

  def robots
    robots = File.read(Rails.root + "config/robots.#{ENV['APP_NAME']}.txt")
    render plain: robots
  end
end
