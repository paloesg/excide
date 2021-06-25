# This background job is to create for permissible (document or folder). We use bg job here because we need to give permissions for all files and documents within a folder if the top layer folder has been given permissions.
class CreatePermissionsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(role, permissible, view_status, download_status, write_status)
    # ----------------------------- Set permission for the top layer ----------------------------------------------
    @permission = Permission.create(role: role, permissible: permissible, can_view: view_status, can_download: download_status, can_write: write_status)
    if @permission.permissible_type == "Folder"
      # Set permission for the documents in the top layer folder
      permissible.documents.each do |d|
        # Update if permission already exists
        d.permissions.where(role: role).present? ? d.permissions.where(role: role).first.update( can_view: view_status, can_download: download_status, can_write: write_status) : Permission.create(role: role, permissible: d, can_view: view_status, can_download: download_status, can_write: write_status)
      end
    # ------------------- Set permissions for the folders descendants if permissible is a folder ------------------
      permissible.descendants.each do |child_folder|
        # Set permission for descendants folder
        child_folder.permissions.where(role: role).present? ? child_folder.permissions.where(role: role).first.update(can_view: view_status, can_download: download_status, can_write: write_status) : Permission.create(role: role, permissible: child_folder, can_view: view_status, can_download: download_status, can_write: write_status)
        # Set permission for the documents within the folders as well
        child_folder.documents.each do |d|
          d.permissions.where(role: role).present? ? d.permissions.where(role: role).first.update( can_view: view_status, can_download: download_status, can_write: write_status) : Permission.create(role: role, permissible: d, can_view: view_status, can_download: download_status, can_write: write_status)
        end
      end
    end
  end
end
