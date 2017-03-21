class SegmentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @segment = Segment.new(segment_params)
    @segment.save!
  end

  private

  def segment_params
    params.require(:segment).permit(
      responses_attributes: [:id, :content, :question_id, :choice_id, :segment_id]
    )
  end
end