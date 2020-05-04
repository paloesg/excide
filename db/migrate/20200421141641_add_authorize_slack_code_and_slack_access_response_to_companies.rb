class AddAuthorizeSlackCodeAndSlackAccessResponseToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :authorize_slack_code, :string
    add_column :companies, :slack_access_response, :json
  end
end
