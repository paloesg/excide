class RecurringWorkflow < ApplicationRecord
  belongs_to :template
  has_many :workflows
end
