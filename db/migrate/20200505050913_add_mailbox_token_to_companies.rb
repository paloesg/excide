class AddMailboxTokenToCompanies < ActiveRecord::Migration[6.0]
  # This migration adds a mailbox_token to all companies and generate mailbox_token for existing company, which is called before_create for new company
  def up
    add_column :companies, :mailbox_token, :string, index: { unique: true }
    Company.reset_column_information
    Company.find_each do |company|
      # send calls the generate_mailbox_token method in company model
      company.send(:generate_mailbox_token)
      # touch: false restricts the save method to update the timestamp
      company.save(touch: false, validate: false)
    end
  end

  def down
    remove_column :companies, :mailbox_token
  end
end
