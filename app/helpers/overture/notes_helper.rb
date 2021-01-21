module Overture::NotesHelper
  def get_notes(company, topic)
    # Only show notes with approved true if current_user's company is investor
    company.investor? ? Note.includes(:notable).where(notable_id: topic.id, approved: true).order(created_at: :asc) : Note.includes(:notable).where(notable_id: topic.id).order(created_at: :asc)
  end
end
