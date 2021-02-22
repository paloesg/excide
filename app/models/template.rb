class Template < ApplicationRecord
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  enum workflow_type: { ordered: 0, unordered: 1 }
  enum deadline_type: { xth_day_of_the_month: 0, days_to_complete: 1 }
  enum template_pattern: { on_demand: 0, daily: 1, weekly: 2, monthly: 3, quarterly: 4, annually: 5 }
  enum freq_unit: {days: 0, weeks: 1, months: 2, years: 3}
  # For motif, users can choose the template type to use. This can also be used to distinguish between symphony and motif
  enum template_type: {onboarding: 0, site_audit: 1, royalty_collection: 2}

  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :tasks, through: :sections, dependent: :destroy
  has_many :document_templates, dependent: :destroy
  has_many :workflows, dependent: :destroy
  has_many :recurring_workflows, dependent: :destroy
  has_many :batches, dependent: :destroy

  belongs_to :company

  after_update :update_workflow_actions

  accepts_nested_attributes_for :sections

  enum business_model: [:ecommerce, :marketplace, :media, :mobile, :saas, :others]

  validates :slug, presence: true

  before_save :data_names_to_json
  # Scope templates that have no batches. Only those that have no batches will be displayed in symphony sidebar
  scope :has_no_batches, -> { includes(:batches).where(batches: { id: nil }) }

  def get_roles
    self.sections.map{|section| section.tasks.map(&:role)}.flatten.compact.uniq
  end

  def workflows_to_csv
    ordered_workflows = workflows.order(created_at: :asc)
    data_names = ordered_workflows.map{|workflow| workflow.data.map(&:name)}.flatten.uniq
    attributes = %w{Id Created\ At Status Remarks} + data_names
    CSV.generate(headers: true) do |csv|
      csv << attributes
      ordered_workflows.each do |workflow|
        row = [
          workflow['id'],
          workflow['created_at'],
          workflow['completed'] ? 'Completed' : workflow.current_section&.section_name,
          workflow['remarks']
        ]
        row_value = []
        data_names.length.times {row_value.push('')}
        workflow.data.each do |data|
          name_index = data_names.index(data.name).to_i
          row_value[name_index] = data.value
        end
        row += row_value
        csv << row
      end
    end
  end

  def self.csv_to_workflows(file)
    imports = {update: [], unchanged: [], not_found: []}
    CSV.foreach(file.path, headers: true, skip_blanks: true) do |row|
      workflow = Workflow.find(row['Id'])
      if workflow
        row_headers = row.headers
        workflow_data_attributes = workflow.data
        # Row with fields (column)
        row.fields.each_with_index do |new_value, index|
          # Find current data attributes with same name of new data attributes name (CSV)
          current_data = workflow_data_attributes.select {|data| data.name == row_headers[index]}.first
          if current_data.present?
            current_data.value = new_value
          else
            new_data = Workflow::Data.new({})
            new_data.name = row_headers[index]
            new_data.value = new_value
            workflow_data_attributes << new_data if new_value and row_headers[index]
          # Fields in row with index greater than 3 is data attributes
          end if index > 3
        end
        workflow.remarks = row['Remarks']
        workflow.data = workflow_data_attributes
        if workflow.changed? and workflow.save
          imports[:update] << workflow
        else
          imports[:unchanged] << workflow
        end
      else
        imports[:not_found] << row['Id']
      end
    end
    imports
  end

  def data_names_to_json
    if (data_names and data_names.is_a? String)
      self.data_names = JSON.parse(data_names)
    end
  end

  def current_workflows
    self.workflows.select{ |w| !w.completed? }
  end

  def company_workflows(company)
    self.workflows.where(company: company)
  end

  def self.assigned_templates(user)
    if user.has_role?(:admin, user.company) or user.has_role? :superadmin
      Template.where(company: user.company).order(:created_at)
    else
      # Work backwards from tasks to get to the templates that have tasks assigned to the user role
      section_ids = Task.where(role_id: user.roles).or(Task.where(user_id: user.id)).pluck(:section_id).uniq
      template_ids = Section.where(id: section_ids).pluck(:template_id).uniq
      Template.where(id: template_ids, company: user.company).order(:created_at)
    end
  end

  # For Motif template type. Set onboarding, site audit and royalty collection template pattern
  def set_recurring_based_on_template_type
    case self.template_type
    when 'onboarding'
      self.template_pattern = "on_demand"
    when 'site_audit'
      self.template_pattern = "annually"
    else
      self.template_pattern = "monthly"
    end
    self.set_recurring_attributes
  end

  def set_recurring_attributes
    # Set freq unit and freq value based on template_pattern
    case self.template_pattern
    when 'daily'
      self.freq_unit = 'days'
      self.freq_value = 1
    when 'weekly'
      self.freq_unit = 'weeks'
      self.freq_value = 1
    when 'monthly'
      self.freq_unit = 'months'
      self.freq_value = 1
    when 'quarterly'
      self.freq_unit = 'months'
      self.freq_value = 3
    when 'annually'
      self.freq_unit = 'years'
      self.freq_value = 1
    end
    self.save
  end

  def set_next_workflow_date(workflow)
    # Used when template is created (template Update action) and scheduler rake task to update next_workflow_date
    self.next_workflow_date = workflow.created_at + self.freq_value.send(self.freq_unit) unless self.template_pattern == 'on_demand'
    self.save
  end

  def self.today
    Template.where(next_workflow_date: Date.current.beginning_of_day..Date.current.end_of_day)
  end

  # updates existing, incomplete workflows and workflow actions' deadlines when the template deadline is updated.
  def update_deadlines
    self.workflows.where(completed: false).each do |wf|
      wf.update_deadlines
    end
  end

  def update_workflow_actions
    self.tasks.each do |task|
      # If there's assigned_user, it will store the ID, else it will be nil
      task.workflow_actions.map { |wfa|
        wfa.assigned_user_id = task.user_id
        wfa.save
      }
    end
  end

  def get_date_range
    case self.template_pattern
    when "daily"
      @date_range = (self.start_date..self.end_date).map(&:to_date)
    when "weekly"
      @date_range = (self.start_date.to_date..self.end_date).step(7).map(&:to_date)
    when "quarterly"
      # Create quarterly month array. Store the current_start_date into an array called @quarters. Append to the array in 3 months interval while the latest element of the array is less than or equals to end_date
      # Set current start date so that we won't overwrite @template.start_date
      @current_start_date = self.start_date
      @date_range = [@current_start_date]
      @date_range << ( @current_start_date += 3.months) while (@date_range.last <= self.end_date)
    end
    return @date_range
  end

  def get_filtering_attributes(year_params)
    @workflows = self.workflows.select{|wf| year_params.present? ? wf.created_at.year.to_s == year_params : wf.created_at.year == Date.current.year}.sort_by{|wf| wf.created_at}

    unless self.on_demand?
      # Determine how many years and months in the filtering options based on deadline
      @years_to_filter = self.end_date.present? ? (self.start_date.year..self.end_date.year).to_a : [Date.current.year]
      # Filtering by months
      @month_years_to_filter = (self.start_date..self.end_date).to_a.map { |d| "#{d.month}-#{d.year}" }.uniq if self.start_date.present?
    end

    @year = year_params.present? ? year_params.to_i : Date.current.year
    return @workflows, @years_to_filter, @month_years_to_filter, @year
  end

  def clone_folder_through_template_tasks(company)
    self.tasks.each do |task|
      # Check whether general template's task has a general folder association.
      if task.folder.present?
        # Check for existing folder that was previously cloned so that there are no duplicated folders. Also, if company is a MF or AF, then it should preset the folders to the parent folder
        @folder = Folder.find_or_create_by(name: task.folder.name , company: company.parent.present? ? company.parent : company)
        task.folder = @folder
        task.save
      end
      # task.clone_folder(@company)
      role = Role.find_or_create_by(name: task.role.name, resource_id: company.id, resource_type: "Company")
      task.role = role
      task.save
    end
  end
end
