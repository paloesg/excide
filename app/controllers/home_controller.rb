class HomeController < ApplicationController
  def index
    @enquiry = Enquiry.new
  end

  def business
  end

  def faq
  end

  def terms
  end

  def privacy
  end

  def digital
    @enquiry = Enquiry.new
  end

  def growth
    @enquiry = Enquiry.new
  end

  def merger
    @enquiry = Enquiry.new
  end

  def robots
    robots = File.read(Rails.root + "config/robots.#{ENV['HEROKU_NAME']}.txt")
    render :text => robots, :layout => false, :content_type => "text/plain"
  end
end
