class Workflow < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :template

  has_many :company_actions

  after_create :create_related_company_actions

  def current_section
    self.template.sections.joins(tasks: :company_actions).where(company_actions: {completed: false}).first
  end

  def next_section
    self.current_section.lower_item
  end

  def current_task
    self.current_section.tasks.joins(:company_actions).where(company_actions: {workflow_id: self.id, completed: false}).first
  end

  def next_task
    self.current_task.lower_item
  end

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
