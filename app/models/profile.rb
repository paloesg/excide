class Profile < ApplicationRecord
  has_rich_text :company_information

  has_one_attached :profile_logo
  acts_as_taggable_on :categories
end
