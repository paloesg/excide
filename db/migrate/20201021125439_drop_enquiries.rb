class DropEnquiries < ActiveRecord::Migration[6.0]
  def change
    drop_table :enquiries
  end
end
