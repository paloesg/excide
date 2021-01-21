class AddOutletRefToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :outlet, type: :uuid, foreign_key: true
    add_column :outlets, :telephone, :string
    add_column :outlets, :address, :string
  end
end
