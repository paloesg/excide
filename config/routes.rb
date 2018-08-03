Rails.application.routes.draw do
  namespace :admin do
    DashboardManifest::DASHBOARDS.each do |dashboard_resource|
      resources dashboard_resource do
        member do
          get :export
          post :import
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
  patch 'workflow_actions/update/:id', to: 'workflow_actions#update', as: :workflow_action

  namespace :symphony do
    get '/search', to: 'home#search'
    get '/check-identifier', to: 'workflows#check_identifier', as: :check_identifier
    resources :users
    resources :document_templates
    resources :documents do
      collection do
        get '/upload-invoice', to: 'documents#upload_invoice', as: :upload_invoice
      end
    end
    resources :archives
    resources :workflows, param: :workflow_identifier, path: '/:workflow_name' do
      member do
        get '/history', to: 'workflows#activities', as: :activities
        post '/reset', to: 'workflows#reset', as: :reset
        get '/section/:section_id', to: 'workflows#show', as: :section
        post '/task/:task_id', to: 'workflows#toggle', as: :task_toggle
        post '/send_reminder/:task_id', to: 'workflows#send_reminder', as: :reminder_task
        post '/stop_reminder/:task_id', to: 'workflows#stop_reminder', as: :stop_reminder
        get '/assign', to: 'workflows#assign', as: :assign
        get '/data-entry', to: 'workflows#data_entry', as: :data_entry
      end
    end
    root to: 'home#index'
  end

  namespace :conductor do
    resources :activation_types
    resources :users do
      collection do
        get :export, to: 'users#export'
        post :import, to: 'users#import'
      end
    end
    resources :activations do
      collection do
        get :history, to: 'activations#activities', as: :activities
      end
      member do
        get '/create-allocations/:type/:count', to: 'activations#create_allocations', as: :create_allocations
        post '/reset', to: 'activations#reset', as: :reset
      end
    end
    resources :allocations do
      collection do
        get :export, to: 'allocations#export'
      end
      member do
        post :last_minute, to: 'allocations#last_minute'
      end
    end
    resources :availabilities do
      collection do
        get '/users/:user_id', to: 'availabilities#user', as: :user
      end
    end
    resources :clients

    root to: 'home#show'
  end

  as :user do
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

  resources :enquiries

  get 'surveys/complete', to: 'surveys#complete', as: :survey_complete
  get 'surveys/:survey_id/section/:section_position', to: 'surveys#section', as: :survey_section
  resources :surveys

  resources :segments
  post 'segment/create-and-new', to: 'segments#create_and_new', as: :segment_create_and_new

  resources :responses

  get 'company/new', to: 'companies#new', as: :new_company
  post 'company/create', to: 'companies#create', as: :create_company
  get 'company/edit', to: 'companies#edit', as: :edit_company
  patch 'company', to: 'companies#update'

  namespace :company do
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
