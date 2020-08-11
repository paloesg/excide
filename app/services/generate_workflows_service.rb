class GenerateWorkflowsService
  def initialize(user, template, document_ids, batch)
    @user = user
    @template = template
    @document_ids = document_ids
    @batch = batch
  end

  def run
    begin
      # If batch is present, then it is creating by batch uploads. Else, it is generating the workflows from template pattern
      if @batch.present?
        set_document_associations
        OpenStruct.new(success?: true, batch: @batch)
      else
        generate_routine(@user, @template)
        OpenStruct.new(success?: true)
      end
    rescue => e
      OpenStruct.new(success?: false, message: e.message)
    end
  end

  private

  def set_document_associations
    @document_ids.each do |document_id|
      @document = Document.find_by(id: document_id)
      generate_workflow
      @document.workflow = @workflow
      @document.save
    end
  end

  def generate_workflow
    # Create new workflow
    @workflow = Workflow.new(user: @user, company: @user.company, template: @template)
    @workflow.template_data(@template)
    @workflow.batch = Batch.find(@batch.id)
    @workflow.save

    return @workflow
  end

  def generate_routine(user, template)
    case template.template_pattern
    when 'monthly'
      # Calculate the number of months between start_date and end_date
      # The range between start date to end date returns every single day in the range. The map find the unique value of month and year, join together with '-' into a string, eg "8-2020", "10-2021"
      if template.start_date.present? and template.end_date.present?
        (template.start_date..template.end_date).map{|d| [d.month, d.year].join('-')}.uniq.each do |month_year| 
          Workflow.create(user_id: user.id, company_id: template.company.id, template_id: template.id, identifier: month_year)
        end
      else
        12.times.map { |i| [(Date.today + (i+1).month).month, (Date.today + (i+1).month).year].join('-') }.each do |month_year|
          Workflow.create(user_id: user.id, company_id: template.company.id, template_id: template.id, identifier: month_year)
        end
      end
    else
      Workflow.create(user_id: user.id, company_id: template.company.id, template_id: template.id)
    end
  end
end
