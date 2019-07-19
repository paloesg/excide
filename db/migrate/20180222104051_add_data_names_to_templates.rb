class AddDataNamesToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :data_names, :json, default: '[]'
  end
end
