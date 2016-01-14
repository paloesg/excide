class Project < ActiveRecord::Base
  belongs_to :business

  enum category: [:category1, :category2, :category3]
  enum budget_type: [:fixed_rate, :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate]
  enum status: [:draft, :in_review, :active, :closed, :completed]
end
