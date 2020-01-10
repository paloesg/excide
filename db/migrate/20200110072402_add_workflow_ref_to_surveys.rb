class AddWorkflowRefToSurveys < ActiveRecord::Migration[6.0]
  def change
    add_reference :surveys, :workflow, foreign_key: true, type: :uuid
  end
end
