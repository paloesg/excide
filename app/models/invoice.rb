class Invoice < ApplicationRecord
  belongs_to :workflow_actions

  validates :invoice_identifier, uniqueness: true

  def build_lineitems
    lineitem = self.line_items.dup
    lineitem << LineItems.new({description: '', quantity: '', price: '', account: ''})
    self.line_items = lineitem
  end

  class LineItems
    attr_accessor :description, :quantity, :price, :account
    def initialize(hash)
      @description = hash['description']
      @quantity = hash['quantity']
      @price = hash['price']
      @account = hash['account']
    end
end