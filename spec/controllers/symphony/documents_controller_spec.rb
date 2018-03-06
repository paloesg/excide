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

    it "should let a user see all the posts" do
      get :index
      expect( response ).to render_template( :index )
    end

    it "should show only company documents" do
      create_list( :template_with_workflow, 3)
      create_list( :template_with_workflow, 3, company: user.company )
      get :index
      assigns( :documents ).each do |workflows_documents|
        workflows_documents.shift.identifier
        workflows_documents.each do |document|
          if document.nil? # Different Document Template
          else
            expect( document[:company_id] ).to eq( user.company.id )
          end
        end
      end
    end

    it "should create company documents" do
      document_params = FactoryBot.attributes_for(:document)
      expect{ post :create, :document => document_params }.to change(Document, :count).by(1)
      expect( Document.last().company_id ).to eq( user.company.id )
    end

    it "should not show other company documents" do
      create_list( :template_with_workflow, 3)
      get :index

      Document.all().each do |document|
        expect( document.id ).not_to eq( user.company.id )
      end

      assigns( :documents ).each do |workflows_documents|
        workflows_documents.shift.identifier
        workflows_documents.each do |document|
          if document.nil? # Different Document Template
          else
            expect( document[:company_id] ).to eq( user.company.id )
          end
        end
      end
    end

    it "should not create other company docments"
  end
end
