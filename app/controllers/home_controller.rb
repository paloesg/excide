class HomeController < ApplicationController
  def index
    @enquiry = Enquiry.new
  end

  def robots
    robots = File.read(Rails.root + "config/robots.#{ENV['APP_NAME']}.txt")
    render :text => robots, :layout => false, :content_type => "text/plain"
  end
end
