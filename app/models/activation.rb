class Activation < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  has_many :allocations

  enum activation_type: [:happy_cart, :flash_sale, :brand_activation]

  validates :start_time, :end_time, presence: true
end
