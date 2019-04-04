module ApplicationHelper
  def get_general_templates
    Template.where(company_id: nil)
  end

  def get_cs_requests
    SurveyTemplate.corp_sec_request
  end

  def sortable(column, title=nil)
    arrow = params[:direction] == "asc" ? "fa fa-caret-down" : "fa fa-caret-up"
    css_class = column == params[:sort] ? "current #{arrow}" : nil
    direction_sort = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    link_to "?page=#{params[:page]}&sort=#{column}&direction=#{direction_sort}" do
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
    link_to(name, '#', class: "add_attribute_fields btn btn-success mr-1", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_add_line_items(name, f, association)
    new_object = f.object.build_line_item.last()
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render "line_items", f: builder
    end
    link_to(name, '#', class: "add_attribute_fields btn btn-primary", data: {id: id, fields: fields.gsub("\n", "")})
  end
end