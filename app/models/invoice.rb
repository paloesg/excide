class Invoice < ApplicationRecord
  belongs_to :workflow

  enum line_amount_type: { exclusive: 0, inclusive: 1, no_tax: 2}

  enum invoice_type: { payable: 0, receivable: 1}

  validates :invoice_type, inclusion: { in: invoice_types.keys }

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
    attr_accessor :description, :quantity, :price, :account, :tax, :tracking_option_1, :tracking_option_2
    def initialize(hash)
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
end
