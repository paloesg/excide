require 'rails_helper'

RSpec.describe "Activations", type: :request do
  describe "GET /conductor/activations" do
    before :each do
      user = FactoryBot.create(:user)
      user.confirmed_at = Time.now
      user.save
      login_as user
    end

    it "works! (now write some real specs)" do
      get conductor_activations_path
      expect(response).to have_http_status(200)
    end
  end
end
