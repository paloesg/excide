class GenerateWorkflowsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(user, template)
    # Create workflows between start and end date for template. nil params is to cater for missing params in the service as batch upload uses the same service
    GenerateWorkflowsService.new(user, template, nil, nil).run
  end
end
