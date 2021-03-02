class Overture::HomeController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  def index

  end

  def financial_performance

  end

  private

  def set_company
    @company = current_user.company
  end
end
