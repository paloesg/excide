class Symphony::SurveyTemplatesController < ApplicationController
  layout 'metronic/application'

  before_action :authenticate_user!

  def index
    @survey_templates = SurveyTemplate.all
  end

  def new 
    @survey_template = SurveyTemplate.new
  end

  def create
    @survey_template = SurveyTemplate.new(survey_template_params)
    @survey_template.company = current_user.company
    if @survey_template.save
      redirect_to edit_symphony_survey_template_path(@survey_template)
    else
      render :new
    end
  end

  def edit
    @survey_template = SurveyTemplate.find_by(slug: params[:survey_template_slug])
  end

  def update
    @survey_template = SurveyTemplate.find_by(slug: params[:survey_template_slug])
    if params[:new_survey_section_submit].present?
      @position = @survey_template.survey_sections.count + 1
      @survey_section = SurveySection.create(display_name: params[:new_survey_section], survey_template_id: @survey_template.id, position: @position)
      if @survey_section.save
        flash[:notice] = 'Survey section was successfully created.'
        redirect_to edit_symphony_survey_template_path(@survey_template)
      else
        flash[:alert] = @survey_section.errors.full_messages.join
      end
    end
    # if params[:template].present?
    #   if @template.update(template_params)
    #     flash[:notice] = 'Template has been saved.'
    #     redirect_to edit_symphony_template_path(@template)
    #   else
    #     flash[:alert] = @template.errors.full_messages.join
    #     render :edit
    #   end
    # else
    # end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  # def set_survey_template
  #   @survey_template = SurveyTemplate.find(params[:id])
  # end

  # Never trust parameters from the scary internet, only allow the white list through.
  def survey_template_params
    params.require(:survey_template).permit(:title, :slug, :survey_type, :company_id)
  end
end