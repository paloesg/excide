class CreateRecurringWorkflows < ActiveRecord::Migration[5.2]
  def change
    create_table :recurring_workflows do |t|
      t.boolean :recurring
      t.integer :freq_value
      t.integer :freq_unit
      t.references :template, foreign_key: true

      t.timestamps
    end
  end
end
