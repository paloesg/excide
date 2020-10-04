class AddPermissibleToPermissions < ActiveRecord::Migration[6.0]
  def change
    add_reference :permissions, :permissible, polymorphic: true, type: :uuid
  end
end
