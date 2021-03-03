class Role < ApplicationRecord
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  has_many :tasks
  has_many :permissions, dependent: :destroy

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify

  def self.defined_roles
    self.all.map
  end

  def self.role_names
    self.all.map do |role|
      role.display_name
    end
  end

  def self.names
    self.all.map do |role|
      role.name
    end
  end

  def display_name
    if self.resource_type.present? and self.resource_id.present?
      "[#{self.resource_type.constantize.find(self.resource_id).name}] #{self.name.humanize}"
    else
      "[Global] #{self.name.humanize}"
    end
  end
end
