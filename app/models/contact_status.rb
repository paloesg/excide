class ContactStatus < ApplicationRecord
  belongs_to :company
  has_many :contacts, dependent: :destroy
end
