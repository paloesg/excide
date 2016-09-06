class HomeController < ApplicationController
  def index
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
  end
  def robots
    robots = File.read(Rails.root + "config/robots.#{ENV['HEROKU_NAME']}.txt")
    render :text => robots, :layout => false, :content_type => "text/plain"
  end
end
