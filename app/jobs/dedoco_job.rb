class DedocoJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(document, task)
    # Do something later
    Dedoco.new(document, task).run
  end
end
