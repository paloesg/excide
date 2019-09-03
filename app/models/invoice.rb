class Invoice < ApplicationRecord
  belongs_to :workflow, dependent: :destroy
  belongs_to :user
  belongs_to :company

  enum status: { rejected: 0, approved: 1}

  enum line_amount_type: { exclusive: 0, inclusive: 1, no_tax: 2}

  enum invoice_type: { payable: 0, receivable: 1}

  validates :invoice_date, :xero_contact_id, :xero_contact_name, presence: true
  validates :invoice_type, inclusion: { in: invoice_types.keys }

  validate :check_basic_line_item_fields
  validate :check_additional_line_item_fields, if: :approved?

  include AASM

  aasm do
    state :created, :initial: true
    state :rejected, :xero_awaiting_approval, :xero_approved, :xero_total_mismatch

    event :reject do
      transitions from: :created, to: :rejected
    end

    event :verified do
      transitions from: :created, to: :xero_awaiting_approval
    end

    event :approved do
      transitions from: :created, to: :xero_approved
    end

    event :mismatch do
      transitions from: :created, to: :xero_total_mismatch
    end
  end

  def line_items
    read_attribute(:line_items).map {|l| LineItem.new(l) }
  end

  def line_items_attributes=(attributes)
    line_items = []
    attributes.each do |index, attrs|
      next if '1' == attrs.delete("_destroy")
      line_items << attrs
    end
    write_attribute(:line_items, line_items)
  end

  def build_line_item
    l = self.line_items.dup
    l << LineItem.new({description: '', quantity: '', price: '', account: '', tax: '', tracking_option_1: '', tracking_option_2: ''})
    self.line_items = l
  end

  def total_amount
    array = self.line_items
    array.inject(0) { |sum, h| sum + (h.quantity.to_i * h.price.to_f)}
  end

  class LineItem
    attr_accessor :item, :description, :quantity, :price, :account, :tax, :tracking_option_1, :tracking_option_2
    def initialize(hash)
      @item = hash['item']
      @description = hash['description']
      @quantity = hash['quantity']
      @price = hash['price']
      @account = hash['account']
      @tax = hash['tax']
      @tracking_option_1 = hash['tracking_option_1']
      @tracking_option_2 = hash['tracking_option_2']
    end
    def persisted?() false; end
    def new_record?() false; end
    def marked_for_destruction?() false; end
    def _destroy() false; end
  end

  private

  def check_basic_line_item_fields
    self.errors.add(:line_items, "description cannot be blank") if self.line_items.map(&:description).include? ""
    self.errors.add(:line_items, "quantity cannot be blank") if self.line_items.map(&:quantity).include? ""
    self.errors.add(:line_items, "price cannot be blank") if self.line_items.map(&:price).include? ""
  end

  def check_additional_line_item_fields
    self.errors.add(:line_items, "account code cannot be blank") if self.line_items.map(&:account).include? ""
    self.errors.add(:line_items, "tax type cannot be blank") if self.line_items.map(&:tax).include? ""
    self.errors.add(:line_items, "tracking cannot be blank") if self.line_items.map(&:tracking_option_1).include? "" or self.line_items.map(&:tracking_option_2).include? ""
  end
end
