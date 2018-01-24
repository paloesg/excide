require 'rails_helper'

RSpec.describe "conductor/activations/new", type: :view do
  before(:each) do
    assign(:conductor_activation, Conductor::Activation.new(
      :activation_type => 1,
      :remarks => "MyText",
      :location => "MyString"
    ))
  end

  it "renders new conductor_activation form" do
    render

    assert_select "form[action=?][method=?]", conductor_activations_path, "post" do

      assert_select "input#conductor_activation_activation_type[name=?]", "conductor_activation[activation_type]"

      assert_select "textarea#conductor_activation_remarks[name=?]", "conductor_activation[remarks]"

      assert_select "input#conductor_activation_location[name=?]", "conductor_activation[location]"
    end
  end
end
