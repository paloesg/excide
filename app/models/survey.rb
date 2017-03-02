class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :business
  belongs_to :template
end
