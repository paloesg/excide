class AddBase64FileDataToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :base_64_file_data, :string
  end
end
