class Workflow < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :template

  after_create :create_related_actions

  private

  # Create all the actions that need to be completed for a workflow that is associated with a company
  def create_related_actions
    sections = self.template.sections
    sections.each do |s|
      s.tasks.each do |t|
        Action.create(task: t, company: self.company, completed: false)
      end
    end
  end
end
