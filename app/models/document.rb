class Document < ActiveRecord::Base
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

  validates :identifier, :file_url, presence: true
end
