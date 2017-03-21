class SurveysController < ApplicationController
  before_action :authenticate_user!

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(survey_params)
    @survey.user_id = current_user.id

    if @survey.save!
      redirect_to survey_section_path(@survey.id)
    end
  end

  def section
    @survey = Survey.find(params[:id])

    @sections = @survey.template.sections
    @section = @sections.first
    @questions = @section.questions

    @segment = Segment.new

    @responses = []
    @questions.each do |question|
      @response = @segment.responses.build
      @response.question_id = question.id
      @responses << @response
    end

  end

  private

  def survey_params
    params.require(:survey).permit(:title, :remarks, :user_id, :business_id, :template_id)
  end
end