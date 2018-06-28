class Template < ActiveRecord::Base
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :document_templates, dependent: :destroy
  has_many :workflows

  belongs_to :company

  accepts_nested_attributes_for :sections

  enum business_model: [:ecommerce, :marketplace, :media, :mobile, :saas, :others]

  validates :title, :slug, :company, presence: true

  def get_roles
    self.sections.map{|section| section.tasks.map(&:role)}.flatten.compact.uniq
  end

  def workflows_to_csv
    data_names = workflows.map{|workflow| workflow.data.map(&:name)}.flatten.uniq
    attributes = %w{Identifier Created Status Remarks} + data_names
    CSV.generate(headers: true) do |csv|
      csv << attributes
      workflows.each do |workflow|
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
    imports = {update: [], unchanged: [], not_found: 0}
    CSV.foreach(file.path, headers: true) do |row|
      workflow = Workflow.find_by_identifier(row['Identifier'])
      if workflow
        data_value = []
        row_headers = row.headers
        workflow_data_attributes = workflow.data

        # Row with fields (column)
        row.fields.each_with_index do |value, index|
          # Find data attributes with same name of data, fields(row) greater than 3 is data attributes
          workflow_data_attributes.each do |data|
            data.value = value if index > 3 and data.name == row_headers[index]
          end
        end

        workflow.remarks = row['Remarks']
        workflow.data = workflow_data_attributes

        if workflow.changed?
          workflow.save
          imports[:update] << workflow
        else
          imports[:unchanged] << workflow
        end
      else
        imports[:not_found] += 1
      end
    end
    imports
  end

  def current_workflows
    self.workflows.select{ |w| !w.completed? }
  end

  def self.assigned_templates(user)
    if user.has_role? :admin, user.company
      Template.where(company: user.company).order(:created_at)
    else
      # Work backwards from tasks to get to the templates that have tasks assigned to the user role
      section_ids = Task.where(role_id: user.roles).pluck(:section_id).uniq
      template_ids = Section.where(id: section_ids).pluck(:template_id).uniq
      Template.where(id: template_ids, company: user.company).order(:created_at)
    end
  end
end
