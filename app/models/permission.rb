class Permission < ApplicationRecord
  belongs_to :permissible, polymorphic: true
  belongs_to :role

  has_many :users, through: :roles
end
