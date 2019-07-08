require 'rails_helper'

RSpec.describe TemplatePolicy, type: :policy do
  subject { described_class }
  let(:company) { Company.new }
  let(:user) { FactoryBot.create(:company_admin) }

  permissions :index? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
