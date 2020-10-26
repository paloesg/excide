class Motif::TemplatesController < ApplicationController

  private
  def set_template
    @template = Template.includes(sections: [tasks: [:role, :user, :document_template]]).find(params[:template_slug])
  end

  def set_company
    @company = current_user.company
  end

  def template_params
    params.require(:template).permit(:title, :company_id, :workflow_type, :deadline_day, :deadline_type, :template_pattern, :start_date, :end_date, :freq_value, :freq_unit, :next_workflow_date, sections_attributes: [:id, :section_name, :position, tasks_attributes: [:id, :child_workflow_template_id, :position, :task_type, :instructions, :role_id, :user_id, :document_template_id, :survey_template_id, :deadline_day, :deadline_type, :set_reminder, :important, :link_url, :image_url, :_destroy] ])
  end
end
