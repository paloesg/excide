class ChangeActionTextRecordIdToString < ActiveRecord::Migration[6.0]
  def up
    change_column :action_text_rich_texts, :record_id, :string
  end

  def down
    change_column :action_text_rich_texts, :record_id, :bigint
  end
end
