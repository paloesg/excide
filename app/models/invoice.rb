class Invoice < ApplicationRecord
  belongs_to :workflow

  def lineitems
    read_attribute(:lineitems).map {|l| Lineitem.new(l) }
  end

  def lineitems_attributes=(attributes)
    lineitems = []
    attributes.each do |index, attrs|
      next if '1' == attrs.delete("_destroy")
      lineitems << attrs
    end
    write_attribute(:lineitems, lineitems)
  end

  def build_lineitem
    l = self.lineitems.dup
    l << Lineitem.new({description: '', quantity: '', price: '', account: '', tax: ''})
    self.lineitems = l
  end

  class Lineitem
    attr_accessor :description, :quantity, :price, :account, :tax
    def initialize(hash)
      @description = hash['description']
      @quantity = hash['quantity']
      @price = hash['price']
      @account = hash['account']
      @tax = hash['tax']
    end
    def persisted?() false; end
    def new_record?() false; end
    def marked_for_destruction?() false; end
    def _destroy() false; end
  end
end