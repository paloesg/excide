require 'rails_helper'

RSpec.describe "conductor/activations/show", type: :view do
  before(:each) do
    @activation = assign(:activation, Activation.create!(
      :activation_type => 2,
      :remarks => "MyText",
      :location => "Location",
      :start_time => Time.now,
      :end_time => Time.now + 1.day
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Location/)
  end
end
