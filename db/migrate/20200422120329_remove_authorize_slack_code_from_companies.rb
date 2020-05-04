class RemoveAuthorizeSlackCodeFromCompanies < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :authorize_slack_code, :string
  end
end
