class Project < ActiveRecord::Base
  belongs_to :business

  enum category: [:category1, :category2, :category3]
  enum budget_type: [:fixed, :rate]
  enum status: [:draft, :pending, :published, :hidden, :closed, :completed]
end
