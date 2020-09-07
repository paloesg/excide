class AddCompanyToFolders < ActiveRecord::Migration[6.0]
  def change
    add_reference :folders, :company, foreign_key: true
  end
end
