require 'csv'

class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :template

  has_many :sections

  accepts_nested_attributes_for :company

  validates :user, presence: true
  validates :template, presence: true
  validates :title, presence: true

  def to_csv
    ::CSV.generate(headers: true) do |csv|
      csv << self.attribute_names

      csv << self.attributes.values_at(*attribute_names)
    end
  end
end
