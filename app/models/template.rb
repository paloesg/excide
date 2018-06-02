class Template < ActiveRecord::Base
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :tasks
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

  def current_workflows
    self.workflows.select{ |w| !w.completed? }
  end

  def self.assigned_templates(user)
    if user.has_role? :admin, user.company
      Template.where(company: user.company)
    else
      # Work backwards from all user actions to get to the templates that have tasks assigned to the user
      task_ids = CompanyAction.all_user_actions(user).pluck(:task_id).uniq
      section_ids = Task.where(id: task_ids).pluck(:section_id).uniq
      template_ids = Section.where(id: section_ids).pluck(:template_id).uniq
      Template.where(id: template_ids, company: user.company)
    end
  end
end
