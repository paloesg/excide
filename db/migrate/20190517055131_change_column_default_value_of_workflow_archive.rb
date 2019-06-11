class ChangeColumnDefaultValueOfWorkflowArchive < ActiveRecord::Migration[5.2]
  def change
  	change_column_default :workflows, :archive, []
  end
end
