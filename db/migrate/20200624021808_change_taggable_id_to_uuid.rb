class ChangeTaggableIdToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :taggings, :uuid, :uuid, default: "gen_random_uuid()", null: false
    
    change_table :taggings do |t|
      t.remove :taggable_id
      t.rename :uuid, :taggable_id
    end

  end
end
