require 'rails_helper'

RSpec.describe Symphony::DocumentsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Document. As you add validations to Document, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  describe "anonymous user" do
    before :each do
      # This simulates an anonymous user
      login_with nil
    end

    it "should be redirected to signin" do
      get :index
      expect( response ).to redirect_to( new_user_session_path )
    end
  end

  describe "login user" do
    let(:company) { FactoryBot.create(:company) }
    let(:user) { FactoryBot.create(:user, company: company) }
    before :each do
      login_with user
    end

    it "should let a user see all the documents" do
      valid_attributes
      get :index, validate_session
      expect( response ).to render_template( :index )
    end
  end
end
