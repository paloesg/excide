class AddDocumentRefToOutlets < ActiveRecord::Migration[6.0]
  def change
    add_reference :outlets, :document, type: :uuid, foreign_key: true
    add_column :outlets, :telephone, :string
    add_column :outlets, :address, :string
  end
end
