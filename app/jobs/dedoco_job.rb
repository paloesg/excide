class DedocoJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(document, task, status, params)
    # Do something later
    if status == "get_builder_link"
      Dedoco.new(document, task, nil).run_position_esign
    else
      Dedoco.new(document, task, params).run
    end
  end
end
