class Symphony::CompaniesController < CompaniesController
  # layout "dashboard/application", except: [:edit]
  layout 'metronic/application', only: [:plan]
  def plan

  end
end