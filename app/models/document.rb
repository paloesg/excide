class Document < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  belongs_to :company
  belongs_to :workflow
  belongs_to :document_template

  validates :identifier, :file_url, presence: true
end
