require './app/services/send_user_reminders'
require 'rails_helper'

RSpec.describe SendUserReminders do
  reminder = FactoryBot.create(:reminder)
  let(:send_user_reminders) { SendUserReminders.run(reminder.user) }

  context "notification sent out" do
    it { p send_user_reminders }
    it "receive email to user" do
      expect(ActionMailer::Base.deliveries.first.subject).to eq('Here are your reminders for today')
      expect(ActionMailer::Base.deliveries.first.to).to eq(["#{reminder.user.email}"])
    end
  end
end
