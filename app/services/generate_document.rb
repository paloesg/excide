class GenerateDocument
  def initialize(user, company, template_slug_param, workflow_param, action_param, document_type_param, batch_id, folder_id)
    @user = user
    @company = company
    @template_slug_param = template_slug_param
    # Generate document through workflow (with action param) and batches
    @workflow_param = workflow_param
    @action_param = action_param # Only document generated through workflow task will have specific action_param (not batches)
    @document_type_param = document_type_param
    @batch_id = batch_id
    # Folder param is for upload documents within a folder (associate document with folder) in MOTIF
    @folder_id = folder_id
  end

  def run
    begin
      create_document
      set_document_associations
      @document.save!
      add_permissions
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  def run_without_associations
    begin
      create_document
      @document.save!
      add_permissions
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  private

  def create_document
    # Create document with the common parameters
    @document = Document.new
    @document.company = @company
    @document.user = @user
    @document.document_template = DocumentTemplate.find_by(title: 'Invoice') if @document_type_param == 'invoice'
  end

  def set_document_associations
    if @folder_id.present?
      @document.folder = Folder.find_by(id: @folder_id)
    else
      generate_workflow
      @document.workflow = @workflow

      if @action_param.present?
        # Document belongs to a specific task in workflow
        @workflow_action = @document.company.workflow_actions.find(@action_param)
        @document.workflow_action = @workflow_action
      end
    end

    return @document
  end

  def generate_workflow
    if @document_type_param == 'batch-uploads'
      @template = Template.find(@template_slug_param)
      # Create new workflow
      @workflow = Workflow.new(user: @document.user, company: @document.company, template: @template, workflowable: @client)
      @workflow.template_data(@template)
      @workflow.batch = Batch.find(@batch_id)
      @workflow.save
    elsif @workflow_param.present?
      # Document belongs to workflow
      @workflow = @document.company.workflows.find(@workflow_param)
    end

    return @workflow
  end

  def add_permissions
    # create permission for the user that uploaded it
    Permission.create(user: @user, can_write: true, can_download: true, can_view: true, permissible: @document)
    # create permission for franchisors
    @franchisors = User.with_role(:franchisor, @company)
    @franchisors.each do |franchisor|
      Permission.create(user: franchisor, can_write: true, can_download: true, can_view: true, permissible: @document) unless @user == franchisor
    end
  end
end
