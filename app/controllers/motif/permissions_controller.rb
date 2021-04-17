class Motif::PermissionsController < ApplicationController
  layout 'motif/application'

  def create
    # Depending on permissible_type, get the instance of the respective permissible (document or folder)
    @permissible = params[:permissible_type] == "folder" ? Folder.find(params[:permissible_id]) : Document.find(params[:permissible_id])
    # Check if permission allows user to write or download. can_write => full access, can_download means can download and view
    @permission = params[:permission] == "Can write" ? Permission.new(user_id: params[:user_id], permissible: @permissible, can_write: true, can_view: true, can_download: true) : Permission.new(user_id: params[:user_id], permissible: @permissible, can_write: false, can_view: true, can_download: true)
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
      if params[:permission]
        if params[:permission] == "Can write"
          @permission.update(user_id: params[:user_id],  permissible: @permissible, can_write: true, can_download: true, can_view: true)
        elsif params[:permission] == "Can download"
          @permission.update(user_id: params[:user_id], permissible: @permissible, can_write: false, can_view: true, can_download: true)
        else
          # Destroy permission if user choose empty option
          @permission.destroy
        end
        format.json { render json: @permission, status: :ok }
      else
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_multiple_permissible
    Folder.destroy(params[:folder_ids]) if params[:folder_ids].present?
    Document.destroy(params[:document_ids]) if params[:document_ids].present?
    respond_to do |format|
      format.html { redirect_back fallback_location: motif_documents_path }
      format.json { head :no_content }
    end
  end
end
