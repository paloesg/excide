require 'rails_helper'

RSpec.describe "conductor/activations/show", type: :view do
  before(:each) do
    @conductor_activation = assign(:conductor_activation, Conductor::Activation.create!(
      :activation_type => 2,
      :remarks => "MyText",
      :location => "Location"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Location/)
  end
end
