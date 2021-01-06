module Motif::PermissionsHelper
  def get_view_permission_count(permissible)
    # Get the total length of the permissible's can_write permission
    permissible = permissible.class.find_by(id: permissible.id)
    permissible.permissions.where(can_view: true).length
  end
end
