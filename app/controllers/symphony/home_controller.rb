class Symphony::HomeController < ApplicationController
  layout 'dashboard/application'
  require 'will_paginate/array'

  before_action :authenticate_user!
  before_action :set_workflow, only: [:show]

  def show
  end

  private

  def set_workflow
    @user = current_user
    @company = @user.company
    @templates = @company.templates
    @workflows = @templates.map(&:workflows).flatten.paginate(page: params[:page], per_page: 10)
  end

end
