class Batch < ApplicationRecord
  belongs_to :company
  belongs_to :template
  has_many :workflows, dependent: :destroy

  # replacement for .first/.last because we use uuids
  def self.first
    order("batches.created_at").first
  end
    
  def self.last
    order("batches.created_at DESC").first
  end
  #this method gets an array of names of roles in all the workflows of Batch. Using this, we can compare the roles with current_user's role to reveal their batches in the INDEX page
  def get_relevant_roles 
    self.workflows.map{|wf| wf.get_roles.map(&:name).map(&:downcase)}.flatten.compact.uniq
  end
end
