class Symphony::SurveysController < ApplicationController
  layout 'metronic/application'

  before_action :authenticate_user!

  def new
    @survey = Survey.new
    @task = Task.find(params[:task])
    @survey_template = SurveyTemplate.find(@task.survey_template_id)
  end

  def create
    @survey = Survey.new(survey_params)
    @survey.user = current_user
    @survey.company = current_user.company
    if @survey.save!
      redirect_to 
    end
  end

  private

  def survey_params
    params.require(:survey).permit(:title, :remarks, :user_id, :company_id, :survey_template_id, segments_attributes: [:name, :position, :_destroy])
  end
end