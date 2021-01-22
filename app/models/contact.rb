class Contact < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'
  belongs_to :contact_status

  has_rich_text :investor_information

  has_many :notes, as: :notable
end
