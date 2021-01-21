class AddCompanyReferenceToOutlets < ActiveRecord::Migration[6.0]
  def change
    add_reference :outlets, :company, type: :uuid, foreign_key: true
  end
end
