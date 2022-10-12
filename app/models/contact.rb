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
    attribute :name, :year_founded, :country_of_origin, :markets_available, :franchise_fees, :average_investment, :royalty, :marketing_fees, :franchisor_tenure, :searchable
    attribute :industry do
      industry.to_s.humanize
    end
    attribute :image_src do
      "#{ brand_logo.present? ? "rails/active_storage/blobs/#{brand_logo.signed_id}/#{brand_logo.filename}" : "packs/media/src/images/motif/avatar-no-photo-692431e773d7106db54841efda3efd80.svg" }"
    end
    attribute :description do
      "#{description.body.present? ? description.body.to_plain_text.truncate(150) : 'No description'}"
    end
  end
end
