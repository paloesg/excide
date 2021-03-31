class Document < ApplicationRecord
  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller&.current_user },
          recipient: ->(_controller, model) { model&.workflow },
          params: {
            filename: ->(_controller, model) { model&.filename }
          }

  belongs_to :company
  belongs_to :document_template
  belongs_to :folder
  belongs_to :outlet
  belongs_to :user
  belongs_to :workflow
  belongs_to :workflow_action
  belongs_to :franchisee

  has_many :permissions, as: :permissible, dependent: :destroy

  has_one_attached :raw_file
  has_many_attached :converted_images

  before_validation :set_filename
  before_destroy :reduce_storage_size
  before_destroy :delete_file_on_s3
  # Tagging documents to indicate where document is created from
  acts_as_taggable_on :tags

  include AlgoliaSearch
  algoliasearch do
    attribute :file_url, :created_at, :updated_at
    attribute :filename do
      "#{ raw_file.present? ? raw_file&.filename : filename }"
    end
    attribute :workflow do
      { id: workflow&.id, template_title: workflow&.template&.title, template_slug: workflow&.template&.slug }
    end
    attribute :document_template do
      { title: document_template&.title }
    end
    attribute :company do
      { name: company&.name, slug: company&.slug }
    end
    tags do
      tags.map(&:name)
    end
  end

  # Attach the blob from direct upload to activestorage and convert all PDF to images
  def attach_and_convert_document(response_key)
    if response_key.present?
      # Attach the blob to the document using the response key given back by active storage through uppy.js file
      attachment = ActiveStorage::Attachment.create(name: 'raw_file', record_type: 'Document', record_id: self.id, blob_id: ActiveStorage::Blob.find_by(key: response_key).id)
    else
      # For cases without response key like document NEW page and workflow "upload file" task
      attachment = ActiveStorage::Attachment.create(name: 'raw_file', record_type: 'Document', record_id: self.id, blob_id: ActiveStorage::Blob.last.id)
    end
    add_to_storage_size(attachment.byte_size)
    # Perform convert job asynchronously to run conversion service
    ConvertPdfToImagesJob.perform_later(self)
  end

  # This method is to add uploaded document to storage size
  def add_to_storage_size(byte_size)
    # Existing companies have nil as storage_used default value, hence must check if its nil.
    self.company.storage_used = self.company.storage_used.present? ? (self.company.storage_used + byte_size) : byte_size
    self.company.save
  end

  private

  def file_format
    # Check file if not saved or exist
    unless MiniMime.lookup_by_filename(self.file_url)
      errors[:document] << "Invalid file format or error uploding"
    end
  end

  def set_filename
    self.filename = File.basename(self.file_url) if self.file_url
  end

  def delete_file_on_s3
    # For those document using the old uploading system
    if self.file_url.present?
      key = self.file_url.split('amazonaws.com/')[1]
      S3_BUCKET.object(key).delete
    end
    # File uploaded by active storage
    self.raw_file.purge_later if self.raw_file.present?
    self.converted_images.purge_later if self.converted_images.present?
  end

  def reduce_storage_size
    self.company.storage_used -= self.raw_file.byte_size
    self.company.save
  end
end
