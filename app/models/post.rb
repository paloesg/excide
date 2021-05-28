class Post < ApplicationRecord
  belongs_to :company
  belongs_to :author, class_name: 'User'

  has_many :documents, dependent: :destroy

  has_rich_text :content
end
