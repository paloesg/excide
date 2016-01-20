class Proposal < ActiveRecord::Base
  belongs_to :profile
  belongs_to :project

  enum status: [:invited, :submitted, :withdrawn, :selected]
end
