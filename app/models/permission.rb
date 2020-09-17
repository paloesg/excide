class Permission < ApplicationRecord
  belongs_to :folder
  belongs_to :role

  has_many :users, through: :roles
end
