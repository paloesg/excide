class Overture::PermissionsController < ApplicationController
  layout 'overture/application'

  before_action :set_permission, only: [:update]

  def create
    # # Depending on permissible_type, get the instance of the respective permissible (document or folder)
    # @permissible = params[:permissible_type] == "folder" ? Folder.find(params[:permissible_id]) : Document.find(params[:permissible_id])
    # # Check if permission allows user to view, download or write. can_write => full access, can_download means can download and view, view just mean viewer the document but no download
    # if params[:permission] == "View"
    #   @permission = Permission.new(user_id: params[:user_id], permissible: @permissible, can_write: false, can_view: true, can_download: false)
    # elsif params[:permission] == "Download"
    #   @permission = Permission.new(user_id: params[:user_id], permissible: @permissible, can_write: false, can_view: true, can_download: true)
    # else
    #   @permission = Permission.new(user_id: params[:user_id], permissible: @permissible, can_write: true, can_view: true, can_download: true)
    # end

    # respond_to do |format|
    #   if @permission.save
    #     format.json { render json: @permission, status: :ok }
    #   else
    #     format.json { render json: @permission.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  def update
    # Store the condition in a hash, and then update the permission using the hash's results
    access_changes = {}
    if params[:status] == "view"
      if @permission.can_view?
        # Disable view access will disable all types of permission
        access_changes['status'] = { can_view: false, can_download: false, can_write: false }
      else
        # Enable view access
        access_changes['status'] = { can_view: true, can_download: @permission.can_download, can_write: @permission.can_write }
      end
    elsif params[:status] == "download"
      if @permission.can_download?
        # Will disable download and write access, keeping view access unchanged
        access_changes['status'] = { can_view: @permission.can_view, can_download: false, can_write: false }
      else
        # Enable download access will enable view access
        access_changes['status'] = { can_view: true, can_download: true, can_write: @permission.can_write}
      end
    # Write access
    else
      if @permission.can_write?
        # Disable write access
        access_changes['status'] = { can_view: @permission.can_view, can_download: @permission.can_download, can_write: false }
      else
        # Enable write access will enable all access
        access_changes['status'] = { can_write: true, can_view: true, can_download: true }
      end
    end
    respond_to do |format|
      if @permission.update(can_view: access_changes['status'][:can_view], can_download: access_changes['status'][:can_download], can_write: access_changes['status'][:can_write])
        format.json { render json: { link_to: overture_documents_path, status: "ok" } }
      else
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end


  end

  private
  def set_permission
    @permission = Permission.find(params[:id])
  end
end
