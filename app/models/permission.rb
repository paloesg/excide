class Permission < ApplicationRecord
  belongs_to :permissible, polymorphic: true
  belongs_to :role
  belongs_to :user

  has_many :users, through: :role
end
