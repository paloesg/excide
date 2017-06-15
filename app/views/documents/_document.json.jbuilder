json.extract! document, :id, :filename, :file_type, :company_id, :date_signed, :date_uploaded, :created_at, :updated_at
json.url document_url(document, format: :json)
