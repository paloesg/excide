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

  def sortable(column, title=nil)
    arrow = params[:direction] == "asc" ? "glyphicon glyphicon-triangle-bottom" : "glyphicon glyphicon-triangle-top"
    css_class = column == params[:sort] ? "current #{arrow}" : nil
    direction_sort = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    link_to "?sort=#{column}&direction=#{direction_sort}" do
      if column == params[:sort]
        "#{title} #{content_tag :i, nil, class: arrow }".html_safe
      else
        "#{title} #{content_tag :i, nil, class: '' }".html_safe
      end 
    end
  end
end
