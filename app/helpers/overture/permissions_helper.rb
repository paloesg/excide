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

  def get_algolia_filter_string
    # Initialize filter string
    filters_string = ""
    current_user.roles.each do |role|
      # Append the string with OR condition to check for those who has role permissions
      filters_string += "permissions.role_id:#{role.id} OR "
    end
    return filters_string
  end
end
