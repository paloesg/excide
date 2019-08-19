class ChangeDocumentApprovedToStatus < ActiveRecord::Migration[5.2]
  def change
    change_column_default :invoices, :approved, nil
    change_column :invoices, :approved, 'integer USING CAST(approved AS integer)'
    rename_column :invoices, :approved, :status
  end
end
