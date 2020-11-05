class Folder < ApplicationRecord
  has_ancestry primary_key_format: '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'

  belongs_to :company
  belongs_to :user

  has_many :documents, dependent: :destroy
  has_many :permissions, as: :permissible, dependent: :destroy
  acts_as_taggable_on :tags
end
