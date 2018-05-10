require 'rails_helper'

RSpec.describe Symphony::DocumentsController, type: :controller do
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
    let(:user) { FactoryBot.create(:user) }
    before :each do
      login_with user
    end

    it "should let a user see all the documents" do
      get :index
      expect( response ).to render_template( :index )
    end
  end
end
