class Symphony::SurveyTemplatesController < ApplicationController
  layout 'metronic/application'

  before_action :authenticate_user!
  before_action :set_survey_template, except: [:index, :new, :create]

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
    
  end

  def update
    if params[:new_survey_section_submit].present?
      @position = @survey_template.survey_sections.count + 1
      @survey_section = SurveySection.create(display_name: params[:new_survey_section], survey_template_id: @survey_template.id, position: @position)
      if @survey_section.save
        flash[:notice] = 'Survey section was successfully created.'
      else
        flash[:alert] = @survey_section.errors.full_messages.join
      end
    end
    if params[:survey_template].present?
      if @survey_template.update(survey_template_params)
        flash[:notice] = 'Survey template has been saved.'
        redirect_to edit_symphony_survey_template_path(@survey_template)
      else
        flash[:alert] = @survey_template.errors.full_messages.join
        render :edit
      end
    else
      redirect_to edit_symphony_survey_template_path(@survey_template)
    end
  end

  def destroy_survey_section
    @survey_section = SurveySection.find(params[:survey_section_id])
    if @survey_section.destroy
      redirect_to edit_symphony_survey_template_path(@survey_template.slug)
    else
      redirect_to symphony_survey_templates_path
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_survey_template
    @survey_template = SurveyTemplate.find_by(slug: params[:survey_template_slug])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def survey_template_params
    params.require(:survey_template).permit(:title, :slug, :survey_type, :company_id, survey_sections_attributes: [:id, :display_name, :position, questions_attributes: [:id, :content, :question_type, :position, :_destroy, choices_attributes: [:id, :position, :content] ] ])
  end
end
