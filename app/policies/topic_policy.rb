class TopicPolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    # Make sure that user's company is linked to the topic
    user.company.investor? ? (user.company == record.company) : (user.company == record.startup)
  end

  class Scope < Scope
    def resolve
      # If company is investor, retrieve all topics with user's company. If company is startup, query by startup column of topics
      if user.company.investor?
        scope.where(company: user.company)
      else
        scope.where(startup: user.company)
      end
    end
  end
end
