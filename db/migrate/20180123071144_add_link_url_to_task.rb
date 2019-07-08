class AddLinkUrlToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :link_url, :string
  end
end
