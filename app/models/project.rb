class Project < ActiveRecord::Base
  belongs_to :business
  belongs_to :project_category

  has_many :proposals

  enum budget_type: [:fixed_rate, :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate]
  enum status: [:draft, :in_review, :active, :closed, :completed]
  enum grant: [:icv, :cdg]
end
