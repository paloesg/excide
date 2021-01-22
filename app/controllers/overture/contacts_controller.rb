class Overture::ContactsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_contact, only: [:show]
  after_action :verify_authorized

  def index
    # Only get investor's contact if they allow it to be public
    @contacts = Contact.where(public: true)
    @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(5)
  end

  def show
    authorize @contact
    @topic = Topic.new
  end

  private
  def set_contact
    @contact = Contact.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end
