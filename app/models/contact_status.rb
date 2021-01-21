class ContactStatus < ApplicationRecord
  belongs_to :startup, class_name: "Company"
end
