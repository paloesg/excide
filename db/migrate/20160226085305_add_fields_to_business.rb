class AddFieldsToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :title, :string
    add_column :businesses, :linkedin_url, :string
  end
end
