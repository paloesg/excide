class AddAwsTextractDataToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :aws_textract_data, :json
  end
end
