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

  validates :company, :client, :event_type, :start_time, :end_time, presence: true
  validate :end_must_be_after_start

  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller && controller.current_user },
          recipient: ->(_controller, model) { model },
          params: {
            event_name: ->(_controller, model) { model&.name },
            start_time: ->(_controller, model) { model&.start_time },
            end_time: ->(_controller, model) { model&.end_time }
          }

  def name
    client.name + ' ' + event_type&.name.to_s
  end

  def update_event_notification
    NotificationMailer.edit_event(self, self.staffer).deliver_later if self.staffer.present?
  end

  private

  def create_event_notification
    NotificationMailer.create_event(self, self.staffer).deliver_later if self.staffer.present?
  end

  def destroy_event_notification
    NotificationMailer.destroy_event(self, self.staffer).deliver if self.staffer.present?
  end

  def end_must_be_after_start
    # Skip this validation if start and end time not present to prevent errors
    return if start_time.blank? or end_time.blank?

    if end_time < start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end