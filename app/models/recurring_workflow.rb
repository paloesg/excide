class RecurringWorkflow < ApplicationRecord
  belongs_to :template
  has_many :workflows

  enum freq_unit: {days: 0, weeks: 1, months: 2, years: 3}
end
