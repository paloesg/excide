class Template < ActiveRecord::Base
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :workflows, dependent: :destroy

  belongs_to :company

  accepts_nested_attributes_for :sections

  enum business_model: [:ecommerce, :marketplace, :media, :mobile, :saas, :others]
end
