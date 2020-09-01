class Event < ApplicationRecord
  after_create :create_event_notification
  after_destroy :destroy_event_notification

  belongs_to :staffer, class_name: 'User'
  belongs_to :company
  belongs_to :client
  belongs_to :event_type, class_name: 'EventType'

  has_one :address, as: :addressable, dependent: :destroy
  has_many :allocations, dependent: :destroy

  accepts_nested_attributes_for :address, reject_if: :all_blank, allow_destroy: true
  validates :company, :event_type, :start_time, presence: true

  # Tagging documents to indicate where document is created from
  acts_as_taggable_on :tags

  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller && controller.current_user },
          recipient: ->(_controller, model) { model },
          params: {
            event_name: ->(_controller, model) { model&.name },
            start_time: ->(_controller, model) { model&.start_time },
            end_time: ->(_controller, model) { model&.end_time }
          }

  scope :client, ->(client) { where(client_id: client) if client.present? }
  scope :event, ->(event_types){ joins(:event_type).where(event_types: { slug: event_types }) if event_types.present? }
  scope :allocation, ->(allocations){ joins(:allocations).where(allocations: { user_id: allocations }) if allocations.present? }
  scope :company, ->(company_id){where(company_id: company_id) if company_id.present?}
  scope :start_time, ->(time){where(start_time: time) if time.present?}

  def name
    client&.name + " " + event_type&.name
  end

  def update_event_notification
    NotificationMailer.edit_event(self, self.staffer).deliver_later if self.staffer.present?
  end

  def project_consultants
    user_id = self.allocations.where(allocation_type: 'consultant').pluck('user_id')
    User.where(id: user_id)
  end

  def associates
    user_id = self.allocations.where(allocation_type: 'associate').pluck('user_id')
    User.where(id: user_id)
  end

  def get_allocated_user
    self.allocations.where.not(user_id: nil)
  end

  private

  def create_event_notification
    NotificationMailer.create_event(self, self.staffer).deliver_later if self.staffer.present?
  end

  def destroy_event_notification
    NotificationMailer.destroy_event(self, self.staffer).deliver if self.staffer.present?
  end
end
