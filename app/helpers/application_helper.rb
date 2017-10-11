module ApplicationHelper
  def get_templates
    Template.where(company_id: nil)
  end

  def get_cs_requests
    SurveyTemplate.corp_sec_request
  end
end
