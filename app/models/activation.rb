class Activation < ActiveRecord::Base
  after_create :create_activation_notification
  after_destroy :destroy_activation_notification

  belongs_to :event_owner, class_name: 'User'
  belongs_to :company
  belongs_to :client
  belongs_to :activation_type

  has_one :address, as: :addressable, dependent: :destroy
  has_many :allocations, dependent: :destroy

  accepts_nested_attributes_for :address, reject_if: :all_blank, allow_destroy: true

  validates :company, :client, :event_owner, :activation_type, :start_time, :end_time, presence: true
  validate :end_must_be_after_start

  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller && controller.current_user },
          recipient: ->(_controller, model) { model },
          params: {
            activation_name: ->(_controller, model) { model&.name },
            start_time: ->(_controller, model) { model&.start_time },
            end_time: ->(_controller, model) { model&.end_time }
          }

  def name
    client.name + ' ' + activation_type.name
  end

  def update_activation_notification
    NotificationMailer.edit_activation(self, self.event_owner).deliver_later if self.event_owner.present?
  end

  private

  def create_activation_notification
    NotificationMailer.create_activation(self, self.event_owner).deliver_later if self.event_owner.present?
  end

  def destroy_activation_notification
    NotificationMailer.destroy_activation(self, self.event_owner).deliver_later if self.event_owner.present?
  end

  def end_must_be_after_start
    # Skip this validation if start and end time not present to prevent errors
    return if start_time.blank? or end_time.blank?

    if end_time < start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
