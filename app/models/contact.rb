class Contact < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'
  belongs_to :contact_status

  has_many :notes, as: :notable

  has_rich_text :description
  has_one_attached :brand_logo

  enum industry: { education: 0, food_and_beverage: 1, retail: 2, beauty_and_wellness: 3, services:4 }

  include AlgoliaSearch
  algoliasearch do
    attribute :name, :industry, :year_founded, :country_of_origin, :markets_available, :franchise_fees, :average_investment, :royalty, :marketing_fees, :franchisor_tenure, :description, :brand_logo
  end
end
