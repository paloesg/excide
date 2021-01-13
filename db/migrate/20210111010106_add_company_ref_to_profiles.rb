class AddCompanyRefToProfiles < ActiveRecord::Migration[6.0]
  def change
    add_reference :profiles, :company, type: :uuid, foreign_key: true
  end
end
