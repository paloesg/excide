class Task < ActiveRecord::Base
  after_create :add_company_action

  belongs_to :section
  belongs_to :role
  belongs_to :document_template

  has_many :reminders, dependent: :destroy
  has_many :company_actions, dependent: :destroy

  enum task_type: [:instructions, :upload_file, :approval, :download_file, :visit_link]

  acts_as_list scope: :section

  validates :instructions, :position, :task_type, presence: true

  def get_company_action(company_id, workflow_identifier = nil)
    workflow_id = workflow_identifier.present? ? Workflow.find_by(identifier: workflow_identifier).id : Workflow.find_by(company_id: company_id, template_id: self.section.template.id).id
    action = self.company_actions.find_by(company_id: company_id, workflow_id: workflow_id)
  end

  private
  # Create company action for existing workflows that this task belongs to
  def add_company_action
    self.section.template.workflows&.each do |workflow|
      CompanyAction.create(task_id: self.id, company_id: workflow.company_id, workflow_id: workflow.id)
    end
  end
end
