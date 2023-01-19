class Motif::TasksController < ApplicationController
  before_action :authenticate_user!

  def update
    @task = Task.find(params[:id])
    respond_to do |format|
      # Upload document and run dedoco code
      if @task.update(task_params)
        DedocoJob.perform_later(@task.document, @task)
        format.html { redirect_to edit_motif_template_path(template_slug: @task.section.template.slug), notice: "Esign has been positioned successfully" }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { redirect_to motif_root_path, alert: "Error positioning esign." }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def task_params
    params.require(:task).permit(:instructions, :position, :section_id, document_attributes: [:id, :raw_file, :company_id])
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end
