class Activation < ActiveRecord::Base
  after_save :activation_notification

  belongs_to :user
  belongs_to :company
  belongs_to :client

  has_one :address, as: :addressable, dependent: :destroy
  has_many :allocations

  enum activation_type: [:happy_cart, :flash_sale, :brand_activation]

  accepts_nested_attributes_for :address, reject_if: :all_blank, allow_destroy: true

  validates :start_time, :end_time, presence: true

  def name
    client.name + ' ' + activation_type.titleize + ' (' + start_time.strftime("%d/%M/%Y") + ')'
  end

  def activation_notification
    NotificationMailer.activation_notification(self, self.user).deliver if self.user.present?
  end
end
