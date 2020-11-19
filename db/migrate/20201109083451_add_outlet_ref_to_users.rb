class AddOutletRefToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :outlet, type: :uuid, foreign_key: true
  end
end
