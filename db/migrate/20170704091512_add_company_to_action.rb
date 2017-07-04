class AddCompanyToAction < ActiveRecord::Migration
  def change
    add_reference :actions, :company, index: true, foreign_key: true
  end
end
