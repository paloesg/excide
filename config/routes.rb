Rails.application.routes.draw do
  namespace :admin do
    DashboardManifest::DASHBOARDS.each do |dashboard_resource|
      resources dashboard_resource do
        member do
          get :export
        end
      end
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

  get 'company/new', to: 'companies#new', as: :new_company
  post 'company/create', to: 'companies#create', as: :create_company
  get 'company/name-reservation', to: 'companies#name_reservation', as: :name_reservation_company
  get 'company/incorporation', to: 'companies#incorporation', as: :incorporation_company
  get 'company/edit', to: 'companies#edit', as: :edit_company
  patch 'company', to: 'companies#update'

  namespace :company do
    resources :projects
  end

  resources :charges, only: [:new, :create]
  resources :dashboards, only: [:show]
  resources :documents

  # Hosted files

  get 'financial-model-course' => redirect('https://excide.s3-ap-southeast-1.amazonaws.com/financial-model-course-info.pdf')

  # Static pages

  get 'faq', to: 'home#faq'
  get 'terms', to: 'home#terms'
  get 'privacy', to: 'home#privacy'
  get 'about-us', to: 'home#about', as: :about

  # VFO services

  get 'virtual-financial-officer', to: 'home#vfo', as: :vfo
  get 'financial-analytics-reporting', to: 'home#financial-analytics-reporting', as: :financial_analytics_reporting
  get 'business-plan-assistance', to: 'home#business-plan-assistance', as: :business_plan_assistance
  get 'corporate-planning', to: 'home#corporate-planning', as: :corporate_planning
  get 'forecasting-sensitivity-analysis', to: 'home#forecasting-sensitivity-analysis', as: :forecasting_sensitivity_analysis
  get 'budgeting-forecasting', to: 'home#budgeting-forecasting', as: :bugeting_forecasting
  get 'ipo-support', to: 'home#ipo-support', as: :ipo_support
  get 'mergers-acquisitions-support', to: 'home#mergers-acquisitions-support', as: :mergers_acquisitions_support
  get 'exit-strategy', to: 'home#exit-strategy', as: :exit_strategy
  get 'turnaround-management', to: 'home#turnaround-management', as: :turnaround_management
  get 'fund-raising', to: 'home#fund-raising', as: :fund_raising

  # Corp sec services

  get 'corporate-secretary', to: 'home#corp-sec', as: :corp_sec
  get 'services', to: 'home#services', as: :services
  get 'accounting-services', to: 'home#accounting-services', as: :accounting
  get 'annual-return-filing', to: 'home#annual-return-filing', as: :return
  get 'bookkeeping', to: 'home#bookkeeping', as: :bookkeeping

  get '/robots.txt' => 'home#robots'

  root 'home#index'
end
