class Project < ActiveRecord::Base
  belongs_to :business
  belongs_to :project_category

  has_many :proposals

  enum budget_type: [:fixed_rate, :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate]
  enum status: [:draft, :in_review, :active, :closed, :completed]
  enum grant: [:icv, :cdg]

  validates :title, :project_category_id, :description, :start_date, :end_date, :budget, presence: true
end
