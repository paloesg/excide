class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true
  belongs_to :user
  belongs_to :workflow_action

  has_rich_text :description
end
