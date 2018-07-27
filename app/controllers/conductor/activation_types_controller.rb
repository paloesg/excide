class Conductor::ActivationTypesController < ApplicationController
  layout 'dashboard/application'

  def index
    @activation_types = ActivationType.all
    @company = Company.find(current_user.company)
  end
end
