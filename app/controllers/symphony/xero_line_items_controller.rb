class Symphony::XeroLineItemsController < ApplicationController
  def show
    @company = current_user.company
    @item = params[:item]
    @item_code_list = @company.xero_line_items.where(item: @item)
    respond_to do |format|
      if @item_code_list.present?
        format.json { render json: @item_code_list[0], status: :ok }
      else
        format.json { render json: @item_code_list[0].errors, status: :unprocessable_entity }
      end
    end
  end
end
