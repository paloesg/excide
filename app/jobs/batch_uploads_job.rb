class BatchUploadsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(user, template, files)
    # Do something later
    GenerateBatchUploads.new(user, template, files).run
  end
end
