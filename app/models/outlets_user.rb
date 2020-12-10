class OutletsUser < ApplicationRecord
  belongs_to :outlet
  belongs_to :user
end
