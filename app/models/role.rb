class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  has_many :tasks

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

  def display_name
    if self.resource_type == "Company"
      self.name.humanize + ' – ' + self.resource_type.constantize.find(self.resource_id).name
    else
      self.name.humanize + ' – Global'
    end
  end
end
