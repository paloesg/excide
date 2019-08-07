require './app/services/send_user_reminders'
require 'rails_helper'

RSpec.describe SendUserReminders do
  set_email = FactoryBot.create(:user, settings: [{
    "reminder_sms": "",
    "reminder_email": "true",
    "reminder_slack": "",
  }])

  set_slack = FactoryBot.create(:user, settings: [{
    "reminder_sms": "",
    "reminder_email": "",
    "reminder_slack": "true",
  }])

  set_sms = FactoryBot.create(:user, settings: [{
    "reminder_sms": "true",
    "reminder_email": "",
    "reminder_slack": "",
  }])

  email_reminder = FactoryBot.create(:reminder, user: set_email)
  slack_reminder = FactoryBot.create(:reminder, user: set_slack)
  sms_reminder = FactoryBot.create(:reminder, user: set_sms)

  send_email_reminder = SendUserReminders.run(email_reminder.user)
  send_slack_reminder = SendUserReminders.run(slack_reminder.user)
  send_sms_reminder = SendUserReminders.run(sms_reminder.user)

  context "Send user reminder" do
    it "receive email to user" do
      expect(send_email_reminder.email_status.present?).to eq(true)
      expect(send_email_reminder.email_status.subject).to eq('Here are your reminders for today')
      expect(send_email_reminder.email_status.to).to eq(["#{email_reminder.user.email}"])
    end
    it "ping to slack" do
      expect(send_slack_reminder.slack_status.present?).to eq(true)
      expect(send_slack_reminder.slack_status.read_body).to eq("ok")
    end
    it "sms reminder sent out" do
      sms_status = send_sms_reminder.sms_status.map{|m| m.status}
      expect(send_sms_reminder.sms_status.present?).to eq(true)
      expect(sms_status).to include("queued")
      expect(sms_status).not_to include("undelivered")
      expect(sms_status).not_to include("failed")
    end
  end
end
