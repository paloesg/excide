class Contact < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'
  belongs_to :contact_status

  has_many :notes, as: :notable

  has_rich_text :description
  has_one_attached :brand_logo

  include AlgoliaSearch
  algoliasearch do
    attribute :name
  end
end
