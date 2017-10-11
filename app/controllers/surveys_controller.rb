class SurveysController < ApplicationController
  layout "dashboard/application"

  before_action :authenticate_user!

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(survey_params)
    @survey.user_id = current_user.id

    if @survey.save!
      redirect_to survey_section_path(@survey.id, 1)
    end
  end

  def section
    @survey = Survey.find(params[:survey_id])
    @position = params[:section_position].to_i

    @sections = @survey.survey_template.survey_sections
    unless @section = @sections.find_by_position(@position)
      redirect_to survey_complete_path
      return
    end

    @questions = @section.questions

    @segment = Segment.new
    @segment.survey_id = @survey.id
    @segment.section_id = @section.id

    @responses = []
    @questions.each do |question|
      @response = @segment.responses.build
      @response.question_id = question.id
      @responses << @response
    end
  end

  def complete
  end

  private

  def survey_params
    params.require(:survey).permit(:title, :remarks, :user_id, :company_id, :survey_template_id)
  end
end