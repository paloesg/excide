class Motif::PermissionsController < ApplicationController
  def create
    @permission = params[:permission] == "Read only" ? Permission.new(permissible_id: params[:document_id], permissible_type: 'documents', can_view: true) : Permission.new(permissible_id: params[:document_id], permissible_type: 'documents', can_download: true)
    respond_to do |format|
      if @permission.save
        format.json { render json: @permission, status: :ok }
      else
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end
end
