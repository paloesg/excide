class AddUserRefToBatches < ActiveRecord::Migration[5.2]
  def change
    add_reference :batches, :user, foreign_key: true
  end
end
