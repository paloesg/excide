require 'rails_helper'

RSpec.describe Invoice, type: :model do
  it { should validate_presence_of(:invoice_date) }
  it { should validate_presence_of(:xero_contact_id) }
  it { should validate_presence_of(:xero_contact_name) }

#  it { should validate_inclusion_of(:invoice_type, in: invoice_types.keys) }

  it { should belong_to(:workflow) }
  it { should belong_to(:user) }

  it { should define_enum_for(:line_amount_type) }
  it { should define_enum_for(:invoice_type) }

end