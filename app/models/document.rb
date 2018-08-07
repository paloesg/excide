class Document < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller&.current_user },
          recipient: ->(_controller, model) { model&.workflow },
          params: {
            filename: ->(_controller, model) { model&.filename }
          }

  after_destroy :delete_file_on_s3

  belongs_to :company
  belongs_to :workflow
  belongs_to :document_template
  belongs_to :user

  validates :identifier, :file_url, presence: true
  validates :file_url, uniqueness: true

  def delete_file_on_s3
    key = self.file_url.split('amazonaws.com/')[1]
    S3_BUCKET.object(key).delete
  end
end