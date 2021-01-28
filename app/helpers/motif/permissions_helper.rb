module Motif::PermissionsHelper
  def get_view_permission_count(permissible)
    # Get the total length of the permissible's can_write permission
    permissible = permissible.class.find_by(id: permissible.id)
    permissible.permissions.includes(:user).where(can_view: true, users: { company: permissible.company }).length
  end

  def set_default_permissions(user)
    # Called when creating teammates
    # This method checks if user is a franchisor. If it is, it will give permissions to all the company's folders & documents
    @folders = user.company.folders
    @documents = user.company.documents
    @folders.each do |folder|
      Permission.create(can_write: true, can_view: true, can_download: true, user: user, permissible: folder)
    end
    @documents.each do |document|
      Permission.create(can_write: true, can_view: true, can_download: true, user: user, permissible: document)
    end
  end
end
