class CreateAgreements < ActiveRecord::Migration[6.0]
  def change
    create_table :agreements, id: :uuid do |t|
      t.uuid :investor_id, foreign_key: true
      t.uuid :startup_id, foreign_key: true
      t.timestamps
    end
  end
end
