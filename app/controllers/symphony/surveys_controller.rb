class Symphony::SurveysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_survey, only: :show
  before_action :require_symphony

  def new
    @survey = Survey.new
    @workflow = Workflow.find_by(id: params[:workflow_id])
    @task = @workflow.template.tasks.find(params[:task])
    @survey_template = SurveyTemplate.find_by(id: @task.survey_template_id)
    @survey.segments.build
  end

  def create
    @survey = Survey.new(survey_params)
    @survey.user = current_user
    @survey.company = current_user.company
    @survey.survey_template = SurveyTemplate.find_by(id: params[:survey][:survey_template_id])
    @survey.workflow = Workflow.find_by(id: params[:workflow_id])
    if @survey.save!
      # If batch exists, then it should update completed to true upon returning to the batch SHOW page
      if @survey.workflow.batch.present?
        @survey.workflow.workflow_actions.find(params[:action_id]).update_attributes(completed: true)
        redirect_to symphony_batch_path(@survey.workflow.template.slug, @survey.workflow.batch.id )
      else
        redirect_to symphony_workflow_path(@survey.workflow.template.slug, @survey.workflow.id), notice: 'Survey successfully created'
      end
    end
  end

  def show
  end

  private

  def set_survey
    @survey = Survey.includes(segments: [:responses]).find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(:title, :remarks, :user_id, :company_id, :survey_template_id, segments_attributes: [:id, :name, :position, :survey_section_id, :_destroy, responses_attributes: [:id, :content, :question_id, :file, :choice_id, multiple_choices_array: [] ]])
  end
end
