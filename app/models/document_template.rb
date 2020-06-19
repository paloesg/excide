class DocumentTemplate < ApplicationRecord
  belongs_to :template
  belongs_to :user

  has_many :documents, dependent: :destroy
  has_many :tasks, dependent: :destroy

  before_destroy :remove_associations

  has_one_attached :file

  validates :title, :template, presence: true

  private

  def remove_associations
    self.tasks.update_all(document_template_id: nil)
    self.documents.update_all(document_template_id: nil)
  end
end
