class Workflow < ApplicationRecord
  include FriendlyId
  friendly_id :slug, use: [:slugged, :finders]

  belongs_to :user
  belongs_to :company
  belongs_to :template
  belongs_to :recurring_workflow
  belongs_to :batch
  belongs_to :workflow_action
  belongs_to :outlet

  # Polymorphic association for any model that needs to be managed through workflows
  belongs_to :workflowable, polymorphic: true

  accepts_nested_attributes_for :workflowable

  has_one :invoice, dependent: :destroy

  has_many :workflow_actions, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :surveys, dependent: :destroy

  after_commit :create_actions_and_trigger_first_task, on: :create
  after_create :short_uuid
  after_create :set_workflow_deadline

  self.implicit_order_column = "created_at"

  acts_as_notification_group

  include PublicActivity::Model
  tracked except: :update,
          owner: ->(controller, _model) { controller && controller.current_user },
          recipient: ->(_controller, model) { model }

  def short_uuid
    self.slug = ShortUUID.shorten id
    self.save
  end

  def set_workflow_deadline
    set_deadline(self.template, self, self.created_at.to_date)
  end

  # updates workflow and workflow actions' deadline based on its date of creation.
  def update_deadlines
    # update workflow deadlines
    set_deadline(self.template, self, self.created_at.to_date)
    # update workflow actions deadlines
    self.template.tasks.each do |task|
      task.workflow_actions.where(completed: false).each do |wfa|
        set_deadline(task, wfa, wfa.created_at.to_date)
      end
    end
  end

  def build_workflowable(params)
    self.workflowable = workflowable_type.constantize.new(params)
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

  def get_last_workflow_action
    self.workflow_actions.includes(:task).where(completed: false).order("tasks.position ASC").first&.id
  end

  def get_task_role_ids
    self.workflow_actions.includes(:task).pluck('tasks.role_id')
  end

  def get_users
    self.template.sections.map{|section| section.tasks.map{|task| task.workflow_actions.map(&:assigned_user)}}.flatten.compact.uniq
  end

  def data
    read_attribute(:data).map {|v| Data.new(v) }
  end

  def data_attributes=(attributes)
    data = []
    attributes.each do |_index, attrs|
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

  def get_workflow_action(task_id)
    self.workflow_actions.where(task_id: task_id).first
  end

  def name
    self.created_at.strftime('%y%m%d-%H%M')
  end

  def progress
    if self.workflow_actions.present?
      self.workflow_actions.where(completed: true).count*100/self.workflow_actions.count
    else
      0
    end
  end

  private

  # Create all the actions that need to be completed for a workflow that is associated with a company
  def create_actions_and_trigger_first_task
    sections = self.template.sections
    sections.each do |s|
      s.tasks.each do |t|
        # workflow actions of an unordered routine can be done in any order, so they are all current actions
        wfa = WorkflowAction.create!(task: t, completed: false, company: self.company, workflow: self, assigned_user_id: t.user_id.present? ? t.user_id : nil, current_action: self.template.unordered? ? true : false)
        set_deadline(t, wfa, wfa.created_at.to_date)
      end
      # Automatically set first task as completed if workflow is part of a batch and first task is a file upload task
      s.tasks.first.get_workflow_action(self.company_id, self.id).update(completed: true) if (s.position == 1 && s.tasks.first.task_type == "upload_file" && self.batch.present?)
    end
    if ordered_workflow?
      trigger_first_task
    else
      # Trigger email for unordered tasks notification
      unordered_tasks_trigger_email
      # self.current_task.get_workflow_action(self.company_id, self.id).notify :users, key: 'workflow_action.unordered_workflow_notify', group: self.template, parameters: { printable_notifiable_name: "#{self.current_task.instructions}", workflow_action_id: self.current_task.get_workflow_action(self.company_id, self.id).id }, send_later: false
    end
  end

  # Set deadline based on settings of template and task (model), while target_model are workflows and workflow actions
  def set_deadline(model, target_model, current_date)
    if model.deadline_type.present?
      case model.deadline_type
      when "xth_day_of_the_month"
        # Check if day exists in that month (for eg, June only have 30 days), so if it is 31st, we bring it forward to the next month.
        if Date.new(current_date.year, current_date.month, -1).day < model.deadline_day
          # The deadline will become the end of the month
          target_model.deadline = Date.new(current_date.year, current_date.month).end_of_month
        else
          # Check if the xth day has past in the current month. If it is, set deadline as the next month
          target_model.deadline = Date.new(current_date.year, current_date.month, model.deadline_day) > Date.current ? Date.new(current_date.year, current_date.month, model.deadline_day) : Date.new(current_date.year, current_date.month, model.deadline_day).next_month()
        end
        # Set to the next business day if self.deadline above is not a work day
        target_model.deadline = 1.business_days.after(target_model.deadline) - 1.day unless target_model.deadline.workday?
      else
        target_model.deadline = model.deadline_day.business_days.after(current_date)
      end
      target_model.save
    end
  end

  def ordered_workflow?
    template.ordered?
  end

  def trigger_first_task
    self.current_task.get_workflow_action(self.company_id, self.id).set_deadline_and_notify(self.current_task)
    # sets the first workflow actions as the current action
    self.current_task.get_workflow_action(self.company_id, self.id).update(current_action: true)
  end

  def unordered_tasks_trigger_email
    self.current_task.get_workflow_action(self.company, self.id).unordered_workflow_create_reminder_and_send_email
  end

  def uppercase_identifier
    self.identifier = identifier.parameterize.upcase
  end
end
