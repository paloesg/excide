module Overture::DocumentsHelper
  # This method is used in investor view of overture dataroom
  def get_shared_item_length(startup, user)
    Folder.roots.includes(:permissions).where(company: startup, permissions: { can_view: true, role_id: [user.roles.map(&:id)] }).length + Document.where(folder_id: nil, company: startup).includes(:permissions).where(permissions: { can_view: true, role_id: [user.roles.map(&:id)] }).length
  end
end
