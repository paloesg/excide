require 'rails_helper'

RSpec.describe "Activations", type: :request do
  describe "GET /conductor/activations" do
    xit "works! (now write some real specs)" do
      get conductor_activations_path
      expect(response).to have_http_status(200)
    end
  end
end
