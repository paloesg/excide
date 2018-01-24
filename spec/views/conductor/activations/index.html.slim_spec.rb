require 'rails_helper'

RSpec.describe "conductor/activations/index", type: :view do
  before(:each) do
    assign(:conductor_activations, [
      Conductor::Activation.create!(
        :activation_type => 2,
        :remarks => "MyText",
        :location => "Location"
      ),
      Conductor::Activation.create!(
        :activation_type => 2,
        :remarks => "MyText",
        :location => "Location"
      )
    ])
  end

  it "renders a list of conductor/activations" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Location".to_s, :count => 2
  end
end
