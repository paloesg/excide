class Motif::CompaniesController < CompaniesController

  def new
    @company = Company.new
    authorize @company
  end

  def create
    
  end

end
