require 'rails_helper'

RSpec.describe "conductor/activations/edit", type: :view do
  before(:each) do
    @company = FactoryBot.create(:company)
    @activation = FactoryBot.create(:activation, company: @company)
    @clients = Client.all
    @event_owners = User.with_role :event_owner, :any
  end

  it "renders the edit activation form" do
    render

    assert_select "form[action=?][method=?]", conductor_activation_path(@activation), "post" do

      assert_select "select#activation_activation_type[name=?]", "activation[activation_type]"

      assert_select "textarea#activation_remarks[name=?]", "activation[remarks]"

      assert_select "input#activation_location[name=?]", "activation[location]"
    end
  end
end
