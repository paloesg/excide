require "rails_helper"

RSpec.describe Conductor::EventsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/conductor/events").to route_to("conductor/events#index")
    end

    it "routes to #new" do
      expect(:get => "/conductor/events/new").to route_to("conductor/events#new")
    end

    it "routes to #show" do
      expect(:get => "/conductor/events/1").to route_to("conductor/events#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/conductor/events/1/edit").to route_to("conductor/events#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/conductor/events").to route_to("conductor/events#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/conductor/events/1").to route_to("conductor/events#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/conductor/events/1").to route_to("conductor/events#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/conductor/events/1").to route_to("conductor/events#destroy", :id => "1")
    end

  end
end
