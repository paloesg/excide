module ApplicationHelper
  def get_templates
    Template.all
  end

  def get_cs_requests
    SurveyTemplate.corp_sec_request
  end
end
