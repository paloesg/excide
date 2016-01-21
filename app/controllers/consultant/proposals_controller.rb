class Consultant::ProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_proposals, only: [:index, :create, :edit, :update]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  def index
  end

  def new
    @proposal = Proposal.new(project_id: params[:project_id])
  end

  def create
    @proposal = Proposal.new(proposal_params)
    @proposal.profile_id = @user.profile.id

    if @proposal.save
      redirect_to project_path(@proposal.project_id), notice: 'Proposal was successfully submitted.'
    else
      render :new
    end
  end

  def show
  end

  def edit
    @proposal = @proposals.find(params[:id])
  end

  def update
    @proposal = @proposals.find(params[:id])

    if @proposal.update(proposal_params)
      redirect_to consultant_proposals_path, notice: 'Your proposal was successfully updated.'
    else
      render :edit
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:id, :profile_id, :project_id, :qualifications, :amount, :file_url)
  end

  def get_proposals
    @user = current_user
    @proposals = @user.profile.proposals
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end