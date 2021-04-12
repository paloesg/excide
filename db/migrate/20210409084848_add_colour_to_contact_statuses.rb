class AddColourToContactStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :contact_statuses, :colour, :string
  end
end
