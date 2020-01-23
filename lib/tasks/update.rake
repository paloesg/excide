namespace :update do
  desc "Update company action to workflow action in activity table"
  task company_action_to_workflow_action: :environment do
    PublicActivity::Activity.where(trackable_type: "CompanyAction", key: "company_action.create").update_all(trackable_type: "WorkflowAction", key: "workflow_action.create")
    PublicActivity::Activity.where(trackable_type: "CompanyAction", key: "company_action.update").update_all(trackable_type: "WorkflowAction", key: "workflow_action.update")
    PublicActivity::Activity.where(trackable_type: "CompanyAction", key: "company_action.destroy").update_all(trackable_type: "WorkflowAction", key: "workflow_action.destroy")
  end

  desc "Archive workflows that have already been completed"
  task archive_completed_workflows: :environment do
    # Check for workflows that still have associated workflow actions, which shows that they have not been archived yet
    Workflow.where(completed: true).includes(:workflow_actions).where.not(workflow_actions: { id: nil }).each do |workflow|
      generate_archive = GenerateArchive.new(workflow).run
      if generate_archive.success?
        puts 'Workflow ID ' + workflow.id.to_s + ' has been archived.'
      else
        puts 'Error archiving workflow ID ' + workflow.id.to_s + ': ' + generate_archive.message
      end
    end
  end

  desc "Rename value of trackable_type from Activation to Event"
  task activation_to_event: :environment do
    activation_activities = PublicActivity::Activity.where(trackable_type: "Activation")
    activation_activities.each do |activity|
      activity.update_column(:trackable_type, "Event")
    end
  end

  desc "Update progress of batches"
  task update_progress_batches: :environment do
    batches = Batch.all
    batches.each do |batch|
      workflow_progress = batch.workflows.where(completed: true).length
      # Check for case where total_action is 0 to prevent NaN error
      task_progress = batch.total_action.blank? or batch.total_action == 0 ? 0 : ((batch.get_completed_actions.length.to_f / batch.total_action) * 100).round(0)
      batch.workflow_progress = workflow_progress
      batch.task_progress = task_progress
      batch.save
    end
  end
end
