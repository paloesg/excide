class Document < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user }, recipient: ->(controller, model) { model&.workflow }, params: { filename: -> (controller, model) { model&.filename }}

  belongs_to :company
  belongs_to :workflow
  belongs_to :document_template
  belongs_to :user

  validates :identifier, :file_url, presence: true
end
