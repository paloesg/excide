class Template < ActiveRecord::Base
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :document_templates, dependent: :destroy
  has_many :workflows

  belongs_to :company

  accepts_nested_attributes_for :sections

  enum business_model: [:ecommerce, :marketplace, :media, :mobile, :saas, :others]

  validates :title, :slug, :company, presence: true

  def get_roles
    self.sections.map{|section| section.tasks.map(&:role)}.flatten.compact.uniq
  end

  class DataName
    attr_accessor :document_templates

    def initialize(hash)
      @name = hash['name']
    end
  end
end
