class Contact < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'
  belongs_to :contact_status

  has_many :notes, as: :notable
  include AlgoliaSearch
  algoliasearch do
    attribute :name
  end
end
