class Motif::PermissionsController < ApplicationController
  def create
    @permission = params[:permission] == "Read only" ? Permission.new(role_id: params[:role_id], permissible_id: params[:document_id], permissible_type: 'documents', can_view: true) : Permission.new(role_id: params[:role_id], permissible_id: params[:document_id], permissible_type: 'documents', can_download: true)
    respond_to do |format|
      if @permission.save
        format.json { render json: @permission, status: :ok }
      else
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @permission = Permission.find(params[:id])
    respond_to do |format|
      if params[:permission] == "Read only" ? @permission.update(role_id: params[:role_id],  permissible_id: params[:document_id], can_view: true, can_download: false) : @permission.update(role_id: params[:role_id], permissible_id: params[:document_id], can_view: false, can_download: true)
        format.json { render json: @permission, status: :ok }
      else
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end
end
