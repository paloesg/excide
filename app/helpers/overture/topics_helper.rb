module Overture::TopicsHelper
  def get_topics(company, question_category)
    if question_category.present?
      # Query topics based on whether a user is investor or startup user
      company.investor? ? Topic.where(company: company, question_category: question_category) : Topic.where(startup_id: company.id, question_category: question_category)
    else
      # Query topics by different col - Investor uses company_id, startup users by startup_id
      company.investor? ? Topic.where(company: company) : Topic.where(startup_id: company.id)
    end
  end
end
