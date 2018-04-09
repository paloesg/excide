require 'rails_helper'

RSpec.describe "Allocations", type: :request do
  describe "GET /allocations" do
    before :each do
      user = FactoryBot.create(:user)
      user.confirmed_at = Time.now
      user.save
      login_as user
    end

    it "works! (now write some real specs)" do
      get conductor_allocations_path
      expect(response).to have_http_status(200)
    end
  end
end
