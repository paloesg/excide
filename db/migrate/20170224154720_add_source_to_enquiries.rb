class AddSourceToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :source, :string
  end
end
