class ChangeWorkflowIdToUuid < ActiveRecord::Migration[5.2]
  class Workflow < ActiveRecord::Base

  end

  class Document < ActiveRecord::Base

  end

  class Invoice < ActiveRecord::Base

  end

  class WorkflowAction < ActiveRecord::Base

  end

  def change
    add_column :workflows, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :documents, :workflow_uuid, :uuid
    add_column :invoices, :workflow_uuid, :uuid
    add_column :workflow_actions, :workflow_uuid, :uuid

    Workflow.find_each do |workflow|
      Document.where(workflow_id: workflow.id).find_each do |document|
        document.workflow_uuid = workflow.uuid
        document.save!
      end

      Invoice.where(workflow_id: workflow.id).find_each do |invoice|
        invoice.workflow_uuid = workflow.uuid
        invoice.save!
      end

      WorkflowAction.where(workflow_id: workflow.id).find_each do |workflow_action|
        workflow_action.workflow_uuid = workflow.uuid
        workflow_action.save!
      end
    end

    remove_reference :documents, :workflow, index:true, foreign_key: true
    remove_reference :invoices, :workflow, index:true, foreign_key: true
    remove_reference :workflow_actions, :workflow, index:true, foreign_key: true

    change_table :workflows do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE workflows ADD PRIMARY KEY (id);"

    rename_column :documents, :workflow_uuid, :workflow_id
    rename_column :invoices, :workflow_uuid, :workflow_id
    rename_column :workflow_actions, :workflow_uuid, :workflow_id

    add_foreign_key :documents, :workflows
    add_foreign_key :invoices, :workflows
    add_foreign_key :workflow_actions, :workflows
  end
end
