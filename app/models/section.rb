class Section < ActiveRecord::Base
  belongs_to :template
  acts_as_list scope: :template

  has_many :questions
  has_many :segments
  has_many :tasks, -> { order(position: :asc) }

  accepts_nested_attributes_for :tasks
end
