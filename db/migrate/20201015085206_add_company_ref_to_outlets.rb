class AddCompanyRefToOutlets < ActiveRecord::Migration[6.0]
  def change
    add_reference :outlets, :company, foreign_key: true
  end
end
