class AddCompanyToTemplate < ActiveRecord::Migration
  def change
    add_reference :templates, :company, index: true, foreign_key: true
  end
end
