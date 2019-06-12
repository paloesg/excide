class Archive
  attr_reader :identifier, :template, :archive, :data, :activities
  def initialize(workflow)
    @archive = workflow.archive
    @identifier = workflow.identifier
    @workflow = @archive["workflow"]
    @template = Template.new(@workflow["template"])
    @data = @workflow["data"]
    @activities = get_activities(@workflow["activity_log"])
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