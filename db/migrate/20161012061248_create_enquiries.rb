class CreateEnquiries < ActiveRecord::Migration
  def change
    create_table :enquiries do |t|
      t.string :name
      t.string :contact
      t.string :email
      t.text :comments

      t.timestamps null: false
    end
  end
end
