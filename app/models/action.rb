class Action < ActiveRecord::Base
  belongs_to :task
  belongs_to :company
end
