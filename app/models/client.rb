class Client < ActiveRecord::Base
  belongs_to :user

  has_many :workflows, as: :workflowable
end
