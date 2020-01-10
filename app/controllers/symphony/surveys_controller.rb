class Symphony::SurveysController < ApplicationController
  layout "dashboard/application"

  before_action :authenticate_user!

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(survey_params)
    @survey.user_id = current_user.id

    if @survey.save!
      redirect_to 
    end
  end

  private

  def survey_params
    params.require(:survey).permit(:title, :remarks, :user_id, :company_id, :survey_template_id)
  end
end