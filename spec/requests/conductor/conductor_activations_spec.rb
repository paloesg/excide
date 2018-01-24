require 'rails_helper'

RSpec.describe "Conductor::Activations", type: :request do
  describe "GET /conductor_activations" do
    it "works! (now write some real specs)" do
      get conductor_activations_path
      expect(response).to have_http_status(200)
    end
  end
end
