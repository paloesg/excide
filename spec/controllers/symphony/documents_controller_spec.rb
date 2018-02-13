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

  it "should let a user see all the posts" do
    login_with create( :user )

    get :index
    expect( response ).to render_template( :index )
    expect( assigns(:user).company ).to eq(assigns(:company))

    # create(:document)
    create(:document_with_template, company: assigns(:company))

    # create(:section)
    create(:template_with_workflow, company: assigns(:company))

    expect( assigns(:user).company ).to eq(assigns(:company))
  end
end
