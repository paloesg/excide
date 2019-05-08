namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on and to generate recurring workflows"

  task :recurring_workflows => :environment do 
    #To check that workflow is recurring today (current date)
    @recurring_workflows = RecurringWorkflow.today
    @recurring_workflows.each do |recurring_workflow|
      GenerateRecurringWorkflow.new(recurring_workflow).run
    end
  end
end