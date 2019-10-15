class RemovePdfConvertedImageFromDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :documents, :pdf_converted_image, :string
  end
end
