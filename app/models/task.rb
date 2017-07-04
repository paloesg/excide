class Task < ActiveRecord::Base
  belongs_to :section

  has_many :actions

  def company_action(company)
    action = self.actions.where(company_id: company.id).first
  end
end
