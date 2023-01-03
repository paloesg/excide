class DedocoJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(document)
    # Do something later
    Dedoco.new(document).run
  end
end
