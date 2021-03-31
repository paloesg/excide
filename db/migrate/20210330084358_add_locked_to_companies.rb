class AddLockedToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :locked, :boolean, default: false
  end
end
