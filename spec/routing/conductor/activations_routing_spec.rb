require "rails_helper"

RSpec.describe Conductor::ActivationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/conductor/activations").to route_to("conductor/activations#index")
    end

    it "routes to #new" do
      expect(:get => "/conductor/activations/new").to route_to("conductor/activations#new")
    end

    it "routes to #show" do
      expect(:get => "/conductor/activations/1").to route_to("conductor/activations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/conductor/activations/1/edit").to route_to("conductor/activations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/conductor/activations").to route_to("conductor/activations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/conductor/activations/1").to route_to("conductor/activations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/conductor/activations/1").to route_to("conductor/activations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/conductor/activations/1").to route_to("conductor/activations#destroy", :id => "1")
    end

  end
end
