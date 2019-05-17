class Template < ApplicationRecord
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  enum workflow_type: { ordered: 0, unordered: 1 }

  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :document_templates, dependent: :destroy
  has_many :workflows
  has_many :recurring_workflows

  belongs_to :company

  accepts_nested_attributes_for :sections

  enum business_model: [:ecommerce, :marketplace, :media, :mobile, :saas, :others]

  validates :title, :slug, presence: true

  before_save :data_names_to_json

  def get_roles
    self.sections.map{|section| section.tasks.map(&:role)}.flatten.compact.uniq
  end

  def workflows_to_csv
    ordered_workflows = workflows.order(created_at: :asc)
    data_names = ordered_workflows.map{|workflow| workflow.data.map(&:name)}.flatten.uniq
    attributes = %w{Identifier Created\ At Status Remarks} + data_names
    CSV.generate(headers: true) do |csv|
      csv << attributes
      ordered_workflows.each do |workflow|
        row = [
          workflow['identifier'],
          workflow['created_at'],
          workflow['completed'] ? 'Completed' : workflow.current_section&.display_name,
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
      workflow = Workflow.find_by_identifier(row['Identifier'])
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
        imports[:not_found] << row['Identifier']
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

  def self.assigned_templates(user)
    if user.has_role? :admin, user.company
      Template.where(company: user.company).or(Template.where(company: nil)).order(:created_at)
    else
      # Work backwards from tasks to get to the templates that have tasks assigned to the user role
      section_ids = Task.where(role_id: user.roles).pluck(:section_id).uniq
      template_ids = Section.where(id: section_ids).pluck(:template_id).uniq
      Template.where(id: template_ids, company: user.company).or(Template.where(company: nil)).order(:created_at)
    end
  end
end
