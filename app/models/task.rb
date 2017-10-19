class Task < ActiveRecord::Base
  belongs_to :section
  acts_as_list scope: :section

  has_many :company_actions
  belongs_to :role

  enum task_type: [:instructions, :upload_file, :approval]

  def get_company_action(company)
    action = self.company_actions.where(company_id: company.id).first
  end
end
