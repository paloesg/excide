module Overture::PermissionsHelper
  def get_current_permissions(permission)
    if permission.can_write?
      "Edit"
    elsif !permission.can_write? and permission.can_download?
      "Download"
    else
      "View"
    end
  end
end
