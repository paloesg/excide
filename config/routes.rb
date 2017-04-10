Rails.application.routes.draw do
  namespace :admin do
    DashboardManifest::DASHBOARDS.each do |dashboard_resource|
      resources dashboard_resource
    end

    root controller: DashboardManifest::ROOT_DASHBOARD, action: :index
  end

  as :user do
    get '/:role/register', to: 'users/registrations#new', as: :register
    get '/:role/login', to: 'devise/sessions#new', as: :login
    get 'logout', to: 'devise/sessions#destroy', as: :logout
  end
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }, path_names: { sign_in: 'login', sign_out: 'logout' }

  get 'account/new', to: 'accounts#new', as: :new_account
  patch 'account/create', to: 'accounts#create', as: :create_account
  get 'account', to: 'accounts#edit', as: :edit_account
  patch 'account', to: 'accounts#update'

  get 'profile', to: 'profiles#show'
  get 'profile/edit', to: 'profiles#edit', as: :edit_profile
  patch 'profile', to: 'profiles#update'

  get 'projects', to: 'projects#index'
  get 'project/:id', to: 'projects#show', as: :project

  resources :enquiries

  get 'surveys/complete', to: 'surveys#complete', as: :survey_complete
  get 'surveys/:survey_id/section/:section_position', to: 'surveys#section', as: :survey_section
  resources :surveys

  resources :segments
  post 'segment/create-and-new', to: 'segments#create_and_new', as: :segment_create_and_new

  resources :responses

  namespace :consultant do
    resources :proposals, except: [:new]
    get 'proposals/new/:project_id', to: 'proposals#new', as: :new_proposal
  end

  get 'business/edit', to: 'business#edit', as: :edit_business
  patch 'business', to: 'business#update'

  namespace :business do
    resources :projects
  end

  # Hosted files

  get 'financial-model-course' => redirect('https://excide.s3-ap-southeast-1.amazonaws.com/financial-model-course-info.pdf')

  # Static pages

  get 'faq', to: 'home#faq'
  get 'terms', to: 'home#terms'
  get 'privacy', to: 'home#privacy'

  get 'virtual-financial-officer', to: 'home#vfo', as: :vfo
  get 'about-us', to: 'home#about', as: :about
  
  # VFO drop down section
  
  get 'financial-analytics-reporting', to: 'home#financial-analytics-reporting', as: :financial_analytics_reporting
  get 'business-plan-assistance', to: 'home#business-plan-assistance', as: :business_plan_assistance
  get 'corporate-planning-structure', to: 'home#corporate-planning-structure', as: :corporate_planning_structure
  get 'forecasting-sensitivity-analysis', to: 'home#forecasting-sensitivity-analysis', as: :forecasting_sensitivity_analysis  
  
  # this part is for the services section, can take out if not necessary
  
  get 'services', to: 'home#services', as: :services
  get 'accounting-services', to: 'home#accounting-services', as: :accounting
  get 'annual-return-filing', to: 'home#annual-return-filing', as: :return
  get 'bookkeeping', to: 'home#bookkeeping', as: :bookkeeping

  get '/robots.txt' => 'home#robots'

  root 'home#index'
end
