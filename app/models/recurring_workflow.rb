class RecurringWorkflow < ApplicationRecord
  belongs_to :template
  belongs_to :company
  has_many :workflows

  enum freq_unit: {days: 0, weeks: 1, months: 2, years: 3}

  def self.today
    RecurringWorkflow.where(next_workflow_date: Date.current.beginning_of_day..Date.current.end_of_day)
  end
end
