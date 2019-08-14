class AddAccessTokenToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :access_token, :json, default: {}
  end
end
