class Workflow < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :template

  # Polymorphic association for any model that needs to be managed through workflows
  belongs_to :workflowable, polymorphic: true

  accepts_nested_attributes_for :workflowable

  has_many :company_actions, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :identifier, uniqueness: true
  validate :check_data_fields

  after_create :create_related_company_actions
  after_create :trigger_first_task
  before_save :uppercase_identifier

  include PublicActivity::Model
  tracked except: :update, owner: ->(controller, model) { controller && controller.current_user }, recipient: ->(controller, model) { model}

  def build_workflowable(params)
    self.workflowable = workflowable_type.constantize.new(params)
  end

  def current_section
    if self.completed
      self.template.sections.last
    else
      self.template.sections.joins(tasks: :company_actions).where(company_actions: {workflow_id: self.id, completed: false}).first || self.template.sections.first
    end
  end

  def next_section
    self.current_section&.lower_item
  end

  def current_task
    self.current_section.tasks.joins(:company_actions).where(company_actions: {workflow_id: self.id, completed: false}).first unless self.completed
  end

  def next_task
    self.current_task&.lower_item
  end

  def get_roles
    self.template.sections.map{|section| section.tasks.map(&:role)}.flatten.compact.uniq
  end

  def get_users
    self.template.sections.map{|section| section.tasks.map{|task| task.company_actions.map(&:user)}}.flatten.compact.uniq
  end

  def data
    read_attribute(:data).map {|v| Data.new(v) }
  end

  def data_attributes=(attributes)
    data = []
    attributes.each do |index, attrs|
      if '1' == attrs.delete("_destroy")
        self.create_activity key: 'workflow.destroy_attribute', owner: User.find_by(id: attrs['user']), params: { attribute: {name: attrs['name'], value: attrs['value']} }
        next
      elsif attrs[:_create]
        self.create_activity key: 'workflow.create_attribute', owner: User.find_by(id: attrs['user']), params: { attribute: {name: attrs['name'], value: attrs['value']} }
      elsif attrs[:_update]
        self.create_activity key: 'workflow.update_attribute', owner: User.find_by(id: attrs['user']), params: { attribute: {name: attrs['name'], value: attrs['value']} }
      end
      next if attrs['name'].empty? && attrs['value'].empty?
      data << attrs
    end
    write_attribute(:data, data)
  end

  def build_data
    d = self.data.dup
    d << Data.new({name: '', value: '', user: '', updated_at: ''})
    self.data = d
  end

  def template_data(template)
    template.data_names.each do |data_name|
      d = self.data.dup
      d << {name: data_name['name'], value: data_name['default']}
      self.data = d
    end
  end

  class Data
    attr_accessor :name, :value, :user, :updated_at
    def initialize(hash)
      @name       = hash['name']
      @value      = hash['value']
      @user       = hash['user']
      @updated_at = hash['updated_at']
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
  def create_related_company_actions
    sections = self.template.sections
    sections.each do |s|
      s.tasks.each do |t|
        CompanyAction.create!(task: t, company: self.company, completed: false, workflow: self)
      end
    end
  end

  def trigger_first_task
    self.current_task.get_company_action(self.company, self.identifier).set_deadline_and_notify(current_task)
  end

  def uppercase_identifier
    self.identifier = identifier.parameterize.upcase
  end

  def check_data_fields
    self.errors.add(:data, "attribute name cannot be blank") if self.data.map(&:name).include? ""
    self.errors.add(:data, "attribute value cannot be blank") if self.data.map(&:value).include? ""
  end
end
