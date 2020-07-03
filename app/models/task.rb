class Task < ApplicationRecord
  validates :days_to_complete, numericality: {allow_nil: true, greater_than_or_equal_to: 1}
  after_create :add_workflow_action

  belongs_to :section
  belongs_to :role
  belongs_to :user
  belongs_to :document_template
  belongs_to :survey_template
  belongs_to :child_workflow_template, class_name: 'Template'
  belongs_to :template

  has_many :reminders, dependent: :destroy
  has_many :workflow_actions, dependent: :destroy

  enum task_type: { instructions: 0, upload_file: 1, approval: 2, download_file: 3, visit_link: 4, upload_photo: 5, enter_data: 6, upload_multiple_files: 8, send_xero_email: 9, create_invoice_payable: 10, xero_send_invoice: 11, create_invoice_receivable: 12, coding_invoice: 13, create_workflow: 14, do_survey: 15 }

  acts_as_list scope: :section

  validates :instructions, :position, :task_type, presence: true
  validate :check_user_and_role_fields

  def get_workflow_action(company_id, workflow_id = nil)
    workflow_id = workflow_id.present? ? Workflow.find(workflow_id).id : Workflow.find_by(company_id: company_id, template_id: self.section.template.id).id

    return self.workflow_actions.find_by(company_id: company_id, workflow_id: workflow_id)
  end

  def check_previous
    Task.where("id < ?", self.id).order(created_at: :asc).last
  end

  def check_both_fields_empty
    ((self.role_id.to_i == 0) && (self.user_id.to_i == 0))
  end

  def check_both_fields_present
    ((self.role_id.to_i != 0) && (self.user_id.to_i != 0))
  end

  private
  # Create company action for existing workflows that this task belongs to
  def add_workflow_action
    self.section.template.workflows&.each do |workflow|
      WorkflowAction.create(task_id: self.id, company_id: workflow.company_id, workflow_id: workflow.id)
    end
  end

  def check_user_and_role_fields
    self.errors.add(:role_id, "or user should be filled ") if (self.check_both_fields_empty || self.check_both_fields_present)
    self.errors.add(:user_id, "or role should be filled ") if (self.check_both_fields_empty || self.check_both_fields_present)
  end
end
