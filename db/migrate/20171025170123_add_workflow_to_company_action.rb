class AddWorkflowToCompanyAction < ActiveRecord::Migration
  def change
    add_reference :company_actions, :workflow, index: true, foreign_key: true
  end
end
