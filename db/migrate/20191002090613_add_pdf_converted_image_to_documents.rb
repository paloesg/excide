class AddPdfConvertedImageToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :pdf_converted_image, :string
  end
end
