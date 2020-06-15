class Document < ApplicationRecord
  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller&.current_user },
          recipient: ->(_controller, model) { model&.workflow },
          params: {
            filename: ->(_controller, model) { model&.filename }
          }

  belongs_to :company
  belongs_to :workflow
  belongs_to :document_template
  belongs_to :user
  belongs_to :workflow_action

  has_one_attached :raw_file
  has_many_attached :converted_images

  before_validation :set_filename
  after_destroy :delete_file_on_s3

  include AlgoliaSearch
  algoliasearch do
    attribute :filename, :file_url, :created_at, :updated_at
    attribute :workflow do
      { id: workflow&.id, template_title: workflow&.template&.title, template_slug: workflow&.template&.slug }
    end
    attribute :document_template do
      { title: document_template&.title }
    end
    attribute :company do
      { name: company&.name, slug: company&.slug }
    end
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
end
