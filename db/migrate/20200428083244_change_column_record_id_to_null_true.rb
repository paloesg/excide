class ChangeColumnRecordIdToNullTrue < ActiveRecord::Migration[6.0]
  def up
    change_column_null :active_storage_attachments, :record_id, true
  end

  def down
    change_column_null :active_storage_attachments, :record_id, false
  end
end
