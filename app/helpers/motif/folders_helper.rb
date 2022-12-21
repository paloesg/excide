module Motif::FoldersHelper
  def get_folders(user)
    # Superadmin sees all the folder in that company, while normal users see their own folders with the addition of files shared with them
    if user.has_role? :superadmin
      Folder.where(company: user.company).where(ancestry: nil)
    else
      Folder.roots.includes(:permissions).where(permissions: { can_view: true, user_id: user.id })
    end
  end
end
