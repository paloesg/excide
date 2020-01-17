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
    @survey.survey_template = SurveyTemplate.find(params[:survey][:survey_template_id])
    @survey.workflow = Workflow.find(params[:workflow_id])
    if @survey.save!
      redirect_to symphony_workflow_path(@survey.workflow.template.slug, @survey.workflow.id), notice: 'Survey successfully created'
    end
  end

  private

  def survey_params
    params.require(:survey).permit(:title, :remarks, :user_id, :company_id, :survey_template_id, segments_attributes: [:id, :name, :position, :_destroy, responses_attributes: [:id, :content, :question_id]])
  end
end