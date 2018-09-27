class DocumentTemplate < ApplicationRecord
  belongs_to :template
  belongs_to :user

  has_many :documents
  has_many :tasks

  before_destroy :remove_associations

  validates :title, :file_url, :template, presence: true

  private

  def remove_associations
    self.tasks.update_all(document_template_id: nil)
    self.documents.update_all(document_template_id: nil)
  end
end
