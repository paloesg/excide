class DocumentTemplate < ActiveRecord::Base
  belongs_to :template
  belongs_to :task
  belongs_to :user
end
