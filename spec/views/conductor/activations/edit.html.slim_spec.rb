require 'rails_helper'

RSpec.describe "conductor/activations/edit", type: :view do
  before(:each) do
    @conductor_activation = assign(:conductor_activation, Conductor::Activation.create!(
      :activation_type => 1,
      :remarks => "MyText",
      :location => "MyString"
    ))
  end

  it "renders the edit conductor_activation form" do
    render

    assert_select "form[action=?][method=?]", conductor_activation_path(@conductor_activation), "post" do

      assert_select "input#conductor_activation_activation_type[name=?]", "conductor_activation[activation_type]"

      assert_select "textarea#conductor_activation_remarks[name=?]", "conductor_activation[remarks]"

      assert_select "input#conductor_activation_location[name=?]", "conductor_activation[location]"
    end
  end
end
