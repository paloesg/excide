class AddTextractIdToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :aws_textract_job_id, :string
  end
end
