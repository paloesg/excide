class SegmentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @segment = Segment.new(segment_params)

    if @segment.save!
      redirect_to survey_section_path(@segment.survey.id, @segment.survey_section.position + 1)
    end
  end

  def create_and_new
    @segment = Segment.new(segment_params)

    if @segment.save!
      redirect_to survey_section_path(@segment.survey.id, @segment.survey_section.position)
    end
  end

  private

  def segment_params
    params.require(:segment).permit(:name, :position, :survey_section_id, :survey_id,
      responses_attributes: [:id, :content, :question_id, :choice_id, :segment_id]
    )
  end
end