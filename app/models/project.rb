class Project < ActiveRecord::Base
  belongs_to :business

  enum category: %w(category1 category2 category3)
  enum budget_type: %w(fixed rate)
  enum status: %w(draft pending published private closed completed)
end
