# This background job is to create or update permission for permissible (document or folder). We use bg job here because we need to give permissions for all files and documents within a folder if the top layer folder has been given permissions.
class PermissionsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(role, permissible, view_status, download_status, write_status)
    # ----------------------------- Set permission for the top layer ----------------------------------------------
    @permission = Permission.create(role: role, permissible: permissible, can_view: view_status, can_download: download_status, can_write: write_status)
    if @permission.permissible_type == "Folder"
      # Set permission for the documents in the top layer folder
      permissible.documents do |d|
        Permission.create(role: role, permissible: d, can_view: view_status, can_download: download_status, can_write: write_status)
      end
    # ------------------- Set permissions for the folders descendants if permissible is a folder ------------------
      permissible.descendants.each do |child_folder|
        # Set permission for descendants folder
        Permission.create(role: role, permissible: child_folder, can_view: view_status, can_download: download_status, can_write: write_status)
        # Set permission for the documents within the folders as well
        child_folder.documents.each do |d|
          Permission.create(role: role, permissible: d, can_view: view_status, can_download: download_status, can_write: write_status)
        end
      end
      puts "Permissible descendants: #{permissible.descendants.length}"
    end
  end
end
