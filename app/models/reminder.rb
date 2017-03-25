class Reminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :business

  enum freq_unit: [:day, :week, :month, :year]
end
