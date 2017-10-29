class Symphony::DocumentsController < DocumentsController
  def create
    @document = Document.new(document_params)
    @document.company = @company

    @workflow = Workflow.find_by(identifier: params[:workflow]) if params[:workflow].present?

    if @document.save
      redirect_to @workflow.nil? ? symphony_documents_path : symphony_workflow_path(@workflow.template.slug, @workflow.identifier), notice: 'Document was successfully created.'
    else
      render :new
    end
  end

  def update
    if @document.update(document_params)
      redirect_to symphony_documents_path, notice: 'Document was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @document.destroy
    respond_to do |format|
      redirect_to symphony_documents_path, notice: 'Document was successfully destroyed.'
    end
  end
end