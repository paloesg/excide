class AddDataNamesToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :data_names, :json, default: '[]'
  end
end
