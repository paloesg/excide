class Symphony::XeroLineItemsController < ApplicationController
  before_action :require_symphony

  def show
    @company = current_user.company
    @item = params[:item_code]
    @item_code_list = @company.xero_line_items.where(item_code: @item)
    respond_to do |format|
      if @item_code_list.present?
        format.json { render json: @item_code_list[0], status: :ok }
      else
        format.json { render json: @item_code_list[0].errors, status: :unprocessable_entity }
      end
    end
  end

  private
  
  # checks if the user's company has Symphony. Links to symphony_policy.rb
  def require_symphony
    authorize :symphony, :index?
  end
end
