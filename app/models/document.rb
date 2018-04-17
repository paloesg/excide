class Document < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }, recipient: ->(controller, model) { model && model.workflow }

  belongs_to :company
  belongs_to :workflow
  belongs_to :document_template
  belongs_to :user

  validates :identifier, :file_url, presence: true
end
