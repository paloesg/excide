class Profile < ActiveRecord::Base
  belongs_to :user

  has_many :experiences, dependent: :destroy
  has_many :qualifications, dependent: :destroy

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :experiences, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :qualifications, :reject_if => :all_blank, :allow_destroy => true
end
