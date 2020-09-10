class Permission < ApplicationRecord
  belongs_to :folder
  belongs_to :role
end
