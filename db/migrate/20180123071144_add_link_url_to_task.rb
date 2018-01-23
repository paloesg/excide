class AddLinkUrlToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :link_url, :string
  end
end
