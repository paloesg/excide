class Profile < ActiveRecord::Base
  belongs_to :user

  has_many :qualifications, dependent: :destroy

  has_many :proposals

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :qualifications, :reject_if => :all_blank, :allow_destroy => true
end
