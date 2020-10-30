class Franchisee < ApplicationRecord
  has_many :outlets, dependent: :destroy
  belongs_to :company

  has_one_attached :profile_picture
end
