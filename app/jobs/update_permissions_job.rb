# This background job is to update permissions for permissible (document or folder).
class UpdatePermissionsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(role, permission, view_status, download_status, write_status)
    # ----------------------------- Update permission for the top layer -------------------------------------------
    permission.update(can_view: view_status, can_download: download_status, can_write: write_status)
    if permission.permissible_type == "Folder"
      # Update permission for the documents in the top layer folder
      permission.permissible.documents.each do |d|
        # Loop the permissions for each documents queried by the role (clicked on by the user)
        d.permissions.where(role: role).each do |document_permission|
          document_permission.update(can_view: view_status, can_download: download_status, can_write: write_status)
        end
      end
    # ------------------- Update permissions for the folders descendants if permissible is a folder ------------------
      permission.permissible.descendants.each do |child_folder|
        # Update permission for descendants folder
        child_folder.permissions.where(role: role).each do |child_folder_permission|
          child_folder_permission.update(can_view: view_status, can_download: download_status, can_write: write_status)
        end
        # Update permission for the documents within the folders as well
        child_folder.documents.each do |d|
          # Loop the permissions for each documents queried by the role (clicked on by the user)
          d.permissions.where(role: role).each do |document_permission|
            document_permission.update(can_view: view_status, can_download: download_status, can_write: write_status)
          end
        end
      end
    end
  end
end
