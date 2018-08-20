# app/jobs/log_job.rb

class EmailJob
  include SuckerPunch::Job

  def perform(event)
    Log.new(event).track
  end
end