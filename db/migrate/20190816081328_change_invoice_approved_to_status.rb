class ChangeInvoiceApprovedToStatus < ActiveRecord::Migration[5.2]
  def up
    change_column_default :invoices, :approved, nil
    change_column :invoices, :approved, 'integer USING CAST(approved AS integer)'
    rename_column :invoices, :approved, :status
  end

  def down
    rename_column :invoices, :status, :approved
    change_column :invoices, :approved, 'boolean USING CAST(approved AS boolean)'
    change_column_default :invoices, :approved, false
  end
end
