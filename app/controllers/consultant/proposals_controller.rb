class Consultant::ProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_proposals, only: [:index, :create]

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
  end

  def update
  end

  private

  def proposal_params
    params.require(:proposal).permit(:id, :profile_id, :project_id, :qualifications, :amount, :file_url)
  end

  def get_proposals
    @user = current_user
    @proposals = @user.profile.proposals
  end
end