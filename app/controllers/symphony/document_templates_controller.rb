class Symphony::DocumentTemplatesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_document_template, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  # GET /document_templates
  # GET /document_templates.json
  def index
    @document_templates = DocumentTemplate.all
  end

  # GET /document_templates/1
  # GET /document_templates/1.json
  def show
  end

  # GET /document_templates/new
  def new
    @document_template = DocumentTemplate.new
  end

  # GET /document_templates/1/edit
  def edit
  end

  # POST /document_templates
  # POST /document_templates.json
  def create
    @document_template = DocumentTemplate.new(document_template_params)

    respond_to do |format|
      if @document_template.save
        format.html { redirect_to symphony_document_templates_path, notice: 'Document template was successfully created.' }
        format.json { render :show, status: :created, location: @document_template }
      else
        format.html { render :new }
        format.json { render json: @document_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /document_templates/1
  # PATCH/PUT /document_templates/1.json
  def update
    respond_to do |format|
      if @document_template.update(document_template_params)
        format.html { redirect_to symphony_document_templates_path, notice: 'Document template was successfully updated.' }
        format.json { render :show, status: :ok, location: @document_template }
      else
        format.html { render :edit }
        format.json { render json: @document_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /document_templates/1
  # DELETE /document_templates/1.json
  def destroy
    @document_template.destroy
    respond_to do |format|
      format.html { redirect_to symphony_document_templates_path, notice: 'Document template was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_company
      @user = current_user
      @company = @user.company
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_document_template
      @document_template = DocumentTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_template_params
      params.require(:document_template).permit(:title, :description, :file_url, :template_id, :task_id, :user_id)
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
