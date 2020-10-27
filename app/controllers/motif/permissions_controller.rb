class Motif::PermissionsController < ApplicationController
  def create
    # Depending on permissible_type, get the instance of the respective permissible (document or folder)
    @permissible = params[:permissible_type] == "folder" ? Folder.find(params[:permissible_id]) : Document.find(params[:permissible_id])
    # Check if permission is read_only or also able to download
    @permission = params[:permission] == "Read only" ? Permission.new(user_id: params[:user_id], permissible: @permissible, can_view: true) : Permission.new(user_id: params[:user_id], permissible: @permissible, can_download: true)
    respond_to do |format|
      if @permission.save
        format.json { render json: @permission, status: :ok }
      else
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @permissible = params[:permissible_type] == "folder" ? Folder.find(params[:permissible_id]) : Document.find(params[:permissible_id])    
    @permission = Permission.find(params[:id])
    respond_to do |format|
      if params[:permission] == "Read only" ? @permission.update(user_id: params[:user_id],  permissible: @permissible, can_view: true, can_download: false) : @permission.update(user_id: params[:user_id], permissible: @permissible, can_view: false, can_download: true)
        format.json { render json: @permission, status: :ok }
      else
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end
end
