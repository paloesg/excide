module ApplicationHelper
  def get_general_templates
    Template.where(company_id: nil)
  end

  def get_company_templates
    Template.where(company: @company)
  end

  def get_cs_requests
    SurveyTemplate.corp_sec_request
  end
end
