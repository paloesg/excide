class Overture::HomeController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  after_action :verify_authorized, except: :index

  def index
    @need_answer = Topic.where(company: @company, status: "need_answer")
    @need_approval = Topic.where(company: @company, status: "need_approval")
    @answered = Topic.where(company: @company, status: "answered")
    @closed = Topic.where(company: @company, status: "closed")
    @activities = PublicActivity::Activity.includes(:owner, :recipient).order("created_at desc").where(trackable_type: "Note").where(recipient_type: "Company", recipient_id: @company.id)
    @posts = policy_scope(Post)
  end

  def financial_performance
    authorize :home, :financial_performance?
  end

  def capitalization_table
    authorize :home, :capitalization_table?
  end

  private

  def set_company
    @company = current_user.company
  end
end
