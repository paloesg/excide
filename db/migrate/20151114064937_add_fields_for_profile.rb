class AddFieldsForProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :headline, :string
    add_column :profiles, :summary, :text
    add_column :profiles, :industry, :string
    add_column :profiles, :specialties, :string
    add_column :profiles, :profile_url, :string
    add_column :profiles, :linkedin_url, :string
    add_column :profiles, :location, :string
    add_column :profiles, :country_code, :string
  end
end
