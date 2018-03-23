require "rails_helper"

RSpec.describe Conductor::AllocationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/conductor/allocations").to route_to("conductor/allocations#index")
    end

    it "routes to #new" do
      expect(:get => "/conductor/allocations/new").to route_to("conductor/allocations#new")
    end

    it "routes to #show" do
      expect(:get => "/conductor/allocations/1").to route_to("conductor/allocations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/conductor/allocations/1/edit").to route_to("conductor/allocations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/conductor/allocations").to route_to("conductor/allocations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/conductor/allocations/1").to route_to("conductor/allocations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/conductor/allocations/1").to route_to("conductor/allocations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/conductor/allocations/1").to route_to("conductor/allocations#destroy", :id => "1")
    end

  end
end
