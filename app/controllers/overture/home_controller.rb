class Overture::HomeController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  after_action :verify_authorized, only: :capitalization_table

  def index

  end

  def financial_performance

  end

  def capitalization_table
    authorize :home, :capitalization_table?
  end

  private

  def set_company
    @company = current_user.company
  end
end
