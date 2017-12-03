class Task < ActiveRecord::Base
  belongs_to :section
  belongs_to :role

  has_many :reminders, dependent: :destroy
  has_many :company_actions, dependent: :destroy

  enum task_type: [:instructions, :upload_file, :approval]

  acts_as_list scope: :section

  validates :instructions, :position, :section, :role, :task_type, presence: true

  def get_company_action(company_id, workflow_identifier = nil)
    workflow_id = workflow_identifier.present? ? Workflow.find_by(identifier: workflow_identifier).id : nil
    action = self.company_actions.find_by(company_id: company_id, workflow_id: workflow_id)
  end
end
