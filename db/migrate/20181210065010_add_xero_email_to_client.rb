class AddXeroEmailToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :xero_email, :string
  end
end
