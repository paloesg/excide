class AddMailboxTokenToCompanies < ActiveRecord::Migration[6.0]
  def up
    add_column :companies, :mailbox_token, :string, index: { unique: true }
    Company.reset_column_information
    Company.find_each do |company|
      company.send(:generate_mailbox_token)
      # touch: false restricts the save method to update the timestamp
      company.save(touch: false, validate: false)
    end
  end

  def down
    remove_column :companies, :mailbox_token
  end
end
