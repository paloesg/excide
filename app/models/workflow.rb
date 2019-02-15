class Workflow < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :template

  # Polymorphic association for any model that needs to be managed through workflows
  belongs_to :workflowable, polymorphic: true

  accepts_nested_attributes_for :workflowable

  has_many :workflow_actions, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :identifier, uniqueness: true
  validate :check_data_fields

  after_create :create_related_workflow_actions
  after_create :trigger_first_task
  before_save :uppercase_identifier

  include PublicActivity::Model
  tracked except: :update,
          owner: ->(controller, _model) { controller && controller.current_user },
          recipient: ->(_controller, model) { model }

  include AlgoliaSearch
  algoliasearch do
    attribute :identifier, :completed, :created_at, :updated_at, :deadline
    attribute :workflowable do
      { client_name: workflowable&.name, client_identifier: workflowable&.identifier }
    end
    attribute :template do
      { title: template.title, slug: template.slug }
    end
    attribute :company do
      { name: company.name, slug: company.slug }
    end
  end

  def build_workflowable(params)
    self.workflowable = workflowable_type.constantize.new(params)
  end

  def next_workflow
    Workflow.where(template: self.template).where('id > ?', self.id).first
  end

  def previous_workflow
    Workflow.where(template: self.template).where('id < ?', self.id).last
  end

  def current_section
    if self.completed
      self.template.sections.last
    else
      self.template.sections.joins(tasks: :workflow_actions).where(workflow_actions: {workflow_id: self.id, completed: false}).first || self.template.sections.first
    end
  end

  def next_section
    self.current_section&.lower_item
  end

  def current_task
    self.current_section.tasks.joins(:workflow_actions).where(workflow_actions: {workflow_id: self.id, completed: false}).first unless self.completed
  end

  def next_task
    self.current_task&.lower_item
  end

  def get_roles
    self.template.sections.map{|section| section.tasks.map(&:role)}.flatten.compact.uniq
  end

  def get_users
    self.template.sections.map{|section| section.tasks.map{|task| task.workflow_actions.map(&:user)}}.flatten.compact.uniq
  end

  def data
    read_attribute(:data).map {|v| Data.new(v) }
  end

  def data_attributes=(attributes)
    data = []
    attributes.each do |index, attrs|
      next if '1' == attrs.delete("_destroy")
      next if attrs['name'].empty? && attrs['value'].empty?
      data << attrs
    end
    write_attribute(:data, data)
  end

  def build_data
    d = self.data.dup
    d << Data.new({name: '', value: '', placeholder: '', user_id: '', updated_at: ''})
    self.data = d
  end

  def template_data(template)
    data_attributes = []
    template.data_names.each do |data|
      data_attributes << {name: data['name'], value: data['default'], placeholder: data['placeholder']}
    end
    self.data = data_attributes
  end

  class Data
    attr_accessor :name, :value, :placeholder, :user_id, :updated_at
    def initialize(hash)
      @name         = hash['name']
      @value        = hash['value']
      @placeholder  = hash['placeholder']
      @user_id      = hash['user_id']
      @updated_at   = hash['updated_at']
    end
    def persisted?() false; end
    def new_record?() false; end
    def marked_for_destruction?() false; end
    def _create() false; end
    def _update() false; end
    def _destroy() false; end
  end

  private

  # Create all the actions that need to be completed for a workflow that is associated with a company
  def create_related_workflow_actions
    sections = self.template.sections
    sections.each do |s|
      s.tasks.each do |t|
        WorkflowAction.create!(task: t, company: self.company, completed: false, workflow: self)
      end
    end
  end

  def trigger_first_task
    self.current_task.get_workflow_action(self.company, self.identifier).set_deadline_and_notify(current_task)
  end

  def uppercase_identifier
    self.identifier = identifier.parameterize.upcase
  end

  def check_data_fields
    self.errors.add(:data, "attribute name cannot be blank") if self.data.map(&:name).include? ""
  end
end