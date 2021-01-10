class Agreement < ApplicationRecord
  belongs_to :investor, class_name: "Company"
  belongs_to :startup, class_name: "Company"
end
