module Overture::TopicsHelper
  def get_topics(company, question_category)
    if question_category.present?
      # Filter by question categories
      policy_scope(Topic).where(question_category: question_category)
    else
      policy_scope(Topic)
    end
  end

  def get_badge_class(topic)
    case topic.status
    when "need_answer"
      "need-answer-text"
    when "need_approval"
      "need-approval-text"
    when "answered"
      "answered-text"
    else
      "closed-text"
    end
  end

  def get_badge_text(topic)
    case topic.status
    when "need_answer"
      "Need Answer"
    when "need_approval"
      "Need Approval"
    when "answered"
      "Answered"
    else
      "Closed"
    end
  end
end
