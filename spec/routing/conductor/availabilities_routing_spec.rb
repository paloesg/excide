require "rails_helper"

RSpec.describe Conductor::AvailabilitiesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/conductor/availabilities").to route_to("conductor/availabilities#index")
    end

    it "routes to #new" do
      expect(:get => "/conductor/availabilities/new").to route_to("conductor/availabilities#new")
    end

    it "routes to #show" do
      expect(:get => "/conductor/availabilities/1").to route_to("conductor/availabilities#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/conductor/availabilities/1/edit").to route_to("conductor/availabilities#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/conductor/availabilities").to route_to("conductor/availabilities#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/conductor/availabilities/1").to route_to("conductor/availabilities#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/conductor/availabilities/1").to route_to("conductor/availabilities#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/conductor/availabilities/1").to route_to("conductor/availabilities#destroy", :id => "1")
    end

  end
end
