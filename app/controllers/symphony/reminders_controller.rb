class Symphony::RemindersController < ApplicationController
  # layout 'dashboard/application'
  layout 'metronic/application'
  before_action :set_reminder, only: [:edit, :update, :cancel]

  def index
    @user = current_user
    @company = @user.company
    @reminders = @company.reminders.where(user: @user)

    @activities = PublicActivity::Activity.includes(:owner, :trackable).where(trackable_type: "Reminder", recipient_id: current_user.id).order("created_at desc")
  end

  def new
    @reminder = Reminder.new
  end

  def create
    @reminder = Reminder.new(reminder_params)
    @reminder.user = current_user
    @reminder.company = current_user.company

    respond_to do |format|
      if @reminder.save
        format.html { redirect_to symphony_reminders_path, notice: 'Reminder was successfully created.' }
        format.json { render :show, status: :created, location: @reminder }
      else
        format.html { render :new }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
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
    params.require(:reminder).permit(:title, :content, :next_reminder, :repeat, :freq_value, :freq_unit, :email, :sms, :slack)
  end
end
