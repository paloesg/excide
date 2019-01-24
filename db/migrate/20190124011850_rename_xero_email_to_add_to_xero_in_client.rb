class RenameXeroEmailToAddToXeroInClient < ActiveRecord::Migration[5.2]
  def change
    rename_column :clients, :xero_email, :add_to_xero
  end
end