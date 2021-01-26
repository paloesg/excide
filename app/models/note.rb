class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true
  belongs_to :contact
  belongs_to :user
  belongs_to :workflow_action
end
