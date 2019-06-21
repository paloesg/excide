class Archive
  attr_reader :id, :identifier, :template, :archive, :data, :activities, :workflowable, :workflowable_type, :remarks, :deadline, :recurring_workflow

  def initialize(workflow)
    @id = workflow.id
    @archive = workflow.archive
    @identifier = workflow.identifier
    @workflow = @archive["workflow"]
    @template = Template.new(@workflow["template"])
    @data = @workflow["data"].map{|d| OpenStruct.new(d)}
    @activities = get_activities(@workflow["activity_log"])
    @workflowable = Workflowable.new(@workflow["workflowable_id"], @workflow["client_name"], @workflow["xero_contact_id"])
    @workflowable_type = @workflow["workflowable_type"]
    @remarks = @workflow["remarks"]
    @deadline = @workflow["deadline"]&.to_datetime
    @recurring_workflow = @workflow["recurring_workflow"]
  end

  class Workflowable
    attr_reader :id, :name, :xero_contact_id
    def initialize(id, client_name, xero_contact_id)
      @id = id
      @name = client_name
      @xero_contact_id = xero_contact_id
    end
  end

  class Template
    attr_reader :slug, :title, :sections
    def initialize(template)
      @slug = template["slug"]
      @title = template["title"]
      @sections = template["sections"]
    end
  end

  def get_activities(activities)
    activities.map {|activity| PublicActivity::Activity.new(activity.with_indifferent_access) }
  end
end
