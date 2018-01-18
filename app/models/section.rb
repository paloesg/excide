class Section < ActiveRecord::Base
  belongs_to :template
  acts_as_list scope: :template

  has_many :tasks, -> { order(position: :asc) }

  accepts_nested_attributes_for :tasks

  validates :unique_name, :display_name, :position, presence: true

  def get_next_section
    self.lower_item
  end
end
