class Workflow < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :template

  has_many :company_actions

  after_create :create_related_company_actions

  private

  # Create all the actions that need to be completed for a workflow that is associated with a company
  def create_related_company_actions
    sections = self.template.sections
    sections.each do |s|
      s.tasks.each do |t|
        CompanyAction.create(task: t, company: self.company, completed: false)
      end
    end
  end
end
