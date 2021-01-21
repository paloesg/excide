module ApplicationHelper
  def title
    if content_for?(:title)
      # allows the title to be set in the view by using t(".title")
      content_for :title
    else
      # look up translation key based on controller path, action name and .title
      # this works identical to the built-in lazy lookup
      t("#{ controller_path.tr('/', '.') }.#{ action_name }.title", default: :site_name)
    end
  end

  def sortable(column, title=nil)
    arrow = params[:direction] == "asc" ? "fa fa-caret-down" : "fa fa-caret-up"
    css_class = column == params[:sort] ? "current #{arrow}" : nil
    direction_sort = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    # get current path url
    url = request.path

    link_to "#{url}?#{request.query_parameters.except(:sort, :direction).to_query}&sort=#{column}&direction=#{direction_sort}" do
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
    link_to(name, '#', class: "add_attribute_fields btn btn-light bg-light", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_add_tasks(name, f, association, locals={})
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', locals.merge!(f: builder))
    end
    link_to(name, '#', class: "add_task_fields btn btn-success pull-right", data: {section_id: f.object.id, id: id, fields: fields.gsub("\n", "")})
  end

  # def link_to_add_choices(name, f, association, locals={})
  #   new_object = f.object.send(association).klass.new
  #   id = new_object.object_id
  #   fields = f.fields_for(association, new_object, child_index: id) do |builder|
  #     render(association.to_s.singularize + '_fields', locals.merge!(f: builder))
  #   end
  #   link_to(name, '#', class: "add_choice_fields mr-3 pull-right btn btn-primary", data: {question_id: f.object.id, id: id, fields: fields.gsub("\n", "")})
  # end

  def link_to_add_segments(name, f, association, locals={})
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', locals.merge!(f: builder))
    end
    link_to(name, '#', class: "add_segment_fields col-sm-2 m-2 btn btn-primary", data: {survey_section_id: @survey_section.id, id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_add_steps(name = nil, f = nil, association = nil, options = nil, html_options = nil, &block)
    # If a block is provided there is no name attribute and the arguments are
    # shifted with one position to the left. This re-assigns those values.
    f, association, options, html_options = name, f, association, options if block_given?

    options = {} if options.nil?
    html_options = {} if html_options.nil?

    if options.include? :locals
      locals = options[:locals]
    else
      locals = { }
    end

    if options.include? :partial
      partial = options[:partial]
    else
      partial = association.to_s.singularize + '_fields'
    end

    # Render the form fields from a file with the association name provided
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, child_index: 'new_record') do |builder|
      render(partial, locals.merge!( f: builder))
    end

    # The rendered fields are sent with the link within the data-form-prepend attr
    html_options['data-form-prepend'] = raw CGI::escapeHTML( fields )
    html_options['href'] = '#'

    content_tag(:a, name, html_options, &block)
  end
end
