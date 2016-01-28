class ProjectCategory < ActiveRecord::Base
  has_many :projects

  enum status: [:active, :inactive]
end
