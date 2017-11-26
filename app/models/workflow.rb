class Workflow < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :template

  # Polymorphic association for any model that needs to be managed through workflows
  belongs_to :workflowable, polymorphic: true

  accepts_nested_attributes_for :workflowable

  has_many :company_actions, dependent: :destroy
  has_many :documents

  after_create :create_related_company_actions

  def build_workflowable(params)
    self.workflowable = workflowable_type.constantize.new(params)
  end

  def current_section
    self.template.sections.joins(tasks: :company_actions).where(company_actions: {completed: false}).first
  end

  def next_section
    self.current_section&.lower_item
  end

  def current_task
    self.current_section.tasks.joins(:company_actions).where(company_actions: {workflow_id: self.id, completed: false}).first
  end

  def next_task
    self.current_task&.lower_item
  end

  private

  # Create all the actions that need to be completed for a workflow that is associated with a company
  def create_related_company_actions
    sections = self.template.sections
    sections.each do |s|
      s.tasks.each do |t|
        CompanyAction.create(task: t, company: self.company, completed: false, workflow: self)
      end
    end
  end
end
