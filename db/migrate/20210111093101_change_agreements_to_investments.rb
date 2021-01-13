class ChangeAgreementsToInvestments < ActiveRecord::Migration[6.0]
  def up
    rename_table :agreements, :investments
  end

  def down
    rename_table :investments, :agreements
  end
end
