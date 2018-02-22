require "rails_helper"

RSpec.describe Conductor::AllocationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/allocations").to route_to("allocations#index")
    end

    it "routes to #new" do
      expect(:get => "/allocations/new").to route_to("allocations#new")
    end

    it "routes to #show" do
      expect(:get => "/allocations/1").to route_to("allocations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/allocations/1/edit").to route_to("allocations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/allocations").to route_to("allocations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/allocations/1").to route_to("allocations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/allocations/1").to route_to("allocations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/allocations/1").to route_to("allocations#destroy", :id => "1")
    end

  end
end
