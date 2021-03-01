module Overture::TopicsHelper
  def get_topics(company, question_category)
    if question_category.present?
      # Filter by question categories
      policy_scope(Topic).where(question_category: question_category)
    else
      policy_scope(Topic)
    end
  end
end
