class ProjectCategory < ActiveRecord::Base
  has_many :projects

  enum status: [:active, :inactive]

  belongs_to :parent, class_name: "ProjectCategory"
  has_many :children, class_name: "ProjectCategory", foreign_key: "parent_id"

  def self.parent_categories
    ProjectCategory.active.joins(:children).uniq
  end

  def self.child_categories
    ProjectCategory.active.joins(:parent)
  end
end
