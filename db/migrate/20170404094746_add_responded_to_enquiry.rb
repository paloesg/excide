class AddRespondedToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :responded, :boolean, default: false
  end
end
