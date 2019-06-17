class Section < ApplicationRecord
  belongs_to :template
  acts_as_list scope: :template

  has_many :tasks, -> { order(position: :asc) }, dependent: :destroy

  accepts_nested_attributes_for :tasks, allow_destroy: true

  validates :unique_name, :position, presence: true

  def get_next_section
    self.lower_item
  end
end
