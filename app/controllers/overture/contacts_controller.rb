class Overture::ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company

  def index
    @contacts = Contact.all
  end
end
