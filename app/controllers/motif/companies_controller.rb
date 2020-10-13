class Motif::CompaniesController < CompaniesController

  def new
    @company = Company.new
    authorize @company
  end

  def create
    @company = Company.new(company_params)
    authorize @company
    @company.connect_xero = false
    if @company.save!
      set_company_roles
      current_user.update(company: @company)
      redirect_to motif_root_path
    end
  end

end
