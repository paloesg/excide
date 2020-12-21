class CreateFranchisee < ActiveRecord::Migration[6.0]
  def change
    create_table :franchisees, id: :uuid do |t|
      t.string :franchise_licensee
      t.string :registered_address
      t.date :commencement_date
      t.date :expiry_date
      t.integer :renewal_period_freq_unit
      t.integer :renewal_period_freq_value
    end
  end
end
