class Task < ActiveRecord::Base
  belongs_to :section
  acts_as_list scope: :section

  has_many :actions

  def company_action(company)
    action = self.actions.where(company_id: company.id).first
  end
end
