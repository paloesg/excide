class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :business
  belongs_to :template

  has_many :sections

  accepts_nested_attributes_for :business

  validates :user, presence: true
  validates :template, presence: true
  validates :title, presence: true
end
