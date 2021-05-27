# This migration removes content from posts as content is using actiontext currently
class RemoveContentFromPosts < ActiveRecord::Migration[6.1]
  def change
    remove_column :posts, :content
  end
end
