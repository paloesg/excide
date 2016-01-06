class AddBusinessIdToProject < ActiveRecord::Migration
  def change
    add_reference :projects, :business, index: true, foreign_key: true
  end
end
