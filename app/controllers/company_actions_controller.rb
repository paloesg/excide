class CompanyActionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company_action

  def update
    respond_to do |format|
      if @company_action.update_attributes(company_action_params)
        format.json { render json: @company_action, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_company_action
    @company_action = CompanyAction.find(params[:id])
  end

  def company_action_params
    params.require(:company_action).permit(:assigned_user_id)
  end
end
