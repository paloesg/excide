class Symphony::RemindersController < ApplicationController
  layout 'dashboard/application'

  def index
    @user = current_user
    @company = @user.company
    @reminders = @user.reminders
  end
end