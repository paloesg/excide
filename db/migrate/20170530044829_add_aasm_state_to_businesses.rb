class AddAasmStateToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :aasm_state, :string
  end
end
