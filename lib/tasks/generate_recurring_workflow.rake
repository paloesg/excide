namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on and to generate recurring workflows"

  task :recurring_workflows => :environment do 
    @recurring_workflows = RecurringWorkflow.all
    @recurring_workflows.each do |recurring_workflow|
    	GenerateRecurringWorkflow.new(recurring_workflow).run
    end
  end
end