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

  # Admin pages for company workflow management
  scope 'admin/companies/:company_name', as: 'admin_company' do
    get 'dashboard', to: 'dashboards#show', as: :dashboard
    get 'edit', to: 'companies#edit', as: :edit
    get 'workflow/:workflow_name', to: 'workflows#show', as: :workflow
    get 'workflow/:workflow_name/:section_id', to: 'workflows#section', as: :workflow_section
    post 'workflow/:workflow_name/:task_id', to: 'workflows#toggle', as: :workflow_task_toggle
    resources :documents
  end

  # Company workflow management
  get 'dashboard', to: 'dashboards#show', as: :dashboard
  get 'workflow/:workflow_name', to: 'workflows#show', as: :company_workflow
  get 'workflow/:workflow_name/:section_id', to: 'workflows#section', as: :company_workflow_section
  post 'workflow/:workflow_name/:task_id', to: 'workflows#toggle', as: :company_workflow_task_toggle
  resources :documents
  patch 'company_actions/update/:id', to: 'company_actions#update', as: :company_action

  namespace :symphony do
    get '/check-identifier', to: 'workflows#check_identifier', as: :check_identifier
    resources :users
    resources :document_templates
    resources :documents
    resources :archives
    resources :workflows, param: :workflow_identifier, path: '/:workflow_name' do
      member do
        get '/reset', to: 'workflows#reset', as: :reset
        get '/section/:section_id', to: 'workflows#section', as: :section
        post '/task/:task_id', to: 'workflows#toggle', as: :task_toggle
        get '/assign', to: 'workflows#assign', as: :assign
      end
    end
    root to: 'home#show'
  end

  namespace :conductor do
    resources :users do
      collection do
        get :export, to: 'users#export'
      end
    end
    resources :activations do
      member do
        get '/create-allocations/:count', to: 'activations#create_allocations', as: :create_allocations
      end
    end
    resources :allocations do
      collection do
        get :export, to: 'allocations#export'
      end
    end
    resources :availabilities do
      collection do
        get '/users/:user_id', to: 'availabilities#user', as: :user
      end
    end

    root to: 'home#show'
  end

  as :user do
    get '/cs/:role/register', to: 'users/registrations#new', as: :register
    get '/cs/:role/login', to: 'devise/sessions#new', as: :login
    get '/:company/:role/register', to: 'users/registrations#new', as: :company_user_register
    get '/:company/login', to: 'devise/sessions#new', as: :company_user_login
    get 'logout', to: 'devise/sessions#destroy', as: :logout
    match 'confirmation' => 'confirmations#update', :via => :put, :as => :update_user_confirmation
  end
  devise_for :users, controllers: { confirmations: 'confirmations', omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }, path_names: { sign_in: 'login', sign_out: 'logout' }

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
  get 'company/edit', to: 'companies#edit', as: :edit_company
  patch 'company', to: 'companies#update'

  namespace :company do
    resources :projects
  end

  resources :charges, only: [:new, :create]

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

  get '/blog' => redirect("https://www.excide.co/blog/")

  root 'home#index'
end
