class DedocoJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(document, task, status)
    # Do something later
    if status == "get_builder_link"
      Dedoco.new(document, task, nil).run_position_esign
    else
      # Dedoco.new(document).run
      puts "By Default, pass #{params}"
    end
  end
end
