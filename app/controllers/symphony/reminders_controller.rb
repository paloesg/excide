class Symphony::RemindersController < ApplicationController
  layout 'dashboard/application'
  before_action :set_reminder, only: [:edit, :update, :cancel]

  def index
    @user = current_user
    @company = @user.company
    @reminders = @user.reminders
  end

  def edit
  end

  def update
    if @reminder.update(reminder_params)
      redirect_to symphony_reminders_path, notice: 'Reminder was successfully updated.'
    else
      render :edit
    end
  end

  def cancel
    if @reminder.update(next_reminder: nil)
      redirect_to symphony_reminders_path, notice: 'Reminder was cancelled.'
    else
      render :edit
    end
  end

  private

  def set_reminder
    @reminder = Reminder.find(params[:id])
  end

  def reminder_params
    params.require(:reminder).permit(:next_reminder, :repeat, :freq_value, :freq_unit, :email, :sms, :slack)
  end
end