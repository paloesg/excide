class DocumentTemplate < ActiveRecord::Base
  belongs_to :template
  belongs_to :user

  has_many :documents
  has_many :tasks

  validates :title, :file_url, :template, presence: true
end
