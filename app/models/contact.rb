class Contact < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'

  has_many :notes, as: :notable
  has_and_belongs_to_many :contact_statuses
end
