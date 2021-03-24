class Overture::PermissionsController < ApplicationController
  layout 'overture/application'

  before_action :set_permission, only: [:update]

  def create
    # Store the condition in a hash, and then create the permission using the hash's results
    permission_changes = {}
    # params comes from access_control.js which indicates which permission icon the user clicked
    if params[:status] == "view"
      # Add permission for view
      permission_changes['status'] = { can_view: true, can_download: false, can_write: false }
    elsif params[:status] == "download"
      permission_changes['status'] = { can_view: true, can_download: true, can_write: false}
    else
      permission_changes['status'] = { can_write: true, can_view: true, can_download: true }
    end
    # Depending on permissible_type, get the instance of the respective permissible (document or folder)
    @permissible = params[:permissible_type] == "folder" ? Folder.find(params[:permissible_id]) : Document.find(params[:permissible_id])
    PermissionsJob.perform_later(Role.find(params[:role_id]), @permissible, permission_changes['status'][:can_view], permission_changes['status'][:can_download], permission_changes['status'][:can_write])
    respond_to do |format|
        format.json { render json: { link_to: session[:previous_url], status: "ok" } }
    end
  end

  def update
    # Store the condition in a hash, and then update the permission using the hash's results
    permission_changes = {}
    # params comes from access_control.js which indicates which permission icon the user clicked
    if params[:status] == "view"
      # If permission is currently can_view, disable view access. Vice versa
      permission_changes['status'] = @permission.can_view? ? { can_view: false, can_download: false, can_write: false } : { can_view: true, can_download: @permission.can_download, can_write: @permission.can_write }
    elsif params[:status] == "download"
      # Similarly for download access
      permission_changes['status'] = @permission.can_download? ? { can_view: @permission.can_view, can_download: false, can_write: false } : { can_view: true, can_download: true, can_write: @permission.can_write}
    else
      # Similar for write access
      permission_changes['status'] = @permission.can_write? ? { can_view: @permission.can_view, can_download: @permission.can_download, can_write: false } : { can_write: true, can_view: true, can_download: true }
    end
    respond_to do |format|
      if @permission.update(can_view: permission_changes['status'][:can_view], can_download: permission_changes['status'][:can_download], can_write: permission_changes['status'][:can_write])
        format.json { render json: { link_to: session[:previous_url], status: "ok" } }
      else
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_multiple_permissible
    Folder.destroy(params[:folder_ids]) if params[:folder_ids].present?
    Document.destroy(params[:document_ids]) if params[:document_ids].present?
    respond_to do |format|
      format.html { redirect_back fallback_location: overture_startups_documents_path }
      format.json { head :no_content }
    end
  end

  def bulk_assign_permissions
    update_group_permissions(params[:permissions][:role_ids], params[:folder_ids], "Folder") if params[:folder_ids].present?
    update_group_permissions(params[:permissions][:role_ids], params[:document_ids], "Document") if params[:document_ids].present?
    respond_to do |format|
      format.html { redirect_back fallback_location: overture_startups_documents_path }
      format.json { head :no_content }
    end
  end

  private
  def set_permission
    @permission = Permission.find(params[:id])
  end

  def update_group_permissions(role_ids, permissible_ids, permissible_type)
    permissible_ids.each do |permissible_id|
      role_ids.each do |role_id|
        @permission = Permission.find_or_create_by(role_id: role_id, permissible_type: permissible_type, permissible_id: permissible_id)
        @permission.can_view = true
        @permission.can_write = true
        @permission.can_download = true
        @permission.save
      end
    end
  end
end
