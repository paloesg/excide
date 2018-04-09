module ApplicationHelper
  def get_general_templates
    Template.where(company_id: nil)
  end

  def get_relevant_templates
    if current_user.has_role? :admin, @company
      Template.where(company: @company)
    else
      Template.where(company: @company).select{|template| (template.get_roles & current_user.roles).any?}
    end
  end

  def get_cs_requests
    SurveyTemplate.corp_sec_request
  end

  def sortable(column, title=nil)
    arrow = params[:direction] == "asc" ? "glyphicon glyphicon-triangle-bottom" : "glyphicon glyphicon-triangle-top"
    css_class = column == params[:sort] ? "current #{arrow}" : nil
    direction_sort = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    link_to params.merge({:sort => column, :direction => direction_sort}) do
      if column == params[:sort]
        "#{title} #{content_tag :i, nil, class: arrow }".html_safe
      else
        "#{title} #{content_tag :i, nil, class: '' }".html_safe
      end
    end
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.build_data.last()
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render association.to_s + "_fields", f: builder
    end
    link_to(name, '#', class: "add_fields btn btn-success", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
