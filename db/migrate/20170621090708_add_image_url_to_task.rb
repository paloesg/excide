class AddImageUrlToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :image_url, :string
  end
end
