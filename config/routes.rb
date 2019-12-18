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
  end

  # Company workflow management
  get 'dashboard', to: 'dashboards#show', as: :dashboard
  get 'workflow/:workflow_name', to: 'workflows#show', as: :company_workflow
  get 'workflow/:workflow_name/:section_id', to: 'workflows#section', as: :company_workflow_section
  post 'workflow/:workflow_name/:task_id', to: 'workflows#toggle', as: :company_workflow_task_toggle
  patch 'workflow_actions/update/:id', to: 'workflow_actions#update', as: :workflow_action

  get '/connect_to_xero', to: 'xero_sessions#connect_to_xero', as: :connect_to_xero
  get '/xero_callback_and_update', to: 'xero_sessions#xero_callback_and_update', as: :xero_callback_and_update
  post '/update_contacts_from_xero', to: 'xero_sessions#update_contacts_from_xero', as: :update_contacts_from_xero
  delete '/disconnect_from_xero', to: 'xero_sessions#disconnect_from_xero', as: :disconnect_from_xero

  namespace :symphony do
    get '/search', to: 'home#search'
    post '/workflow/task/toggle-all', to: 'workflows#toggle_all', as: :task_toggle_all
    get '/xero_item_code', to: 'invoices#get_xero_item_code_detail'

    resources :templates, param: :template_slug, except: [:destroy]
    post '/templates/:template_slug/create_section', to: 'templates#create_section', as: :create_section
    delete '/templates/:template_slug/destroy_section', to: 'templates#destroy_section', as: :destroy_section

    resources :clients do
      member do
        post '/xero_create', to: 'clients#xero_create', as: :xero_create
      end
    end
    resources :users do
      member do
        patch '/change_company', to: 'users#change_company', as: :change_company
        get '/notification_settings', to: 'users#notification_settings', as: :notification_settings
        patch '/update_notification', to: 'users#update_notification', as: :update_notification
      end
      collection do
        patch '/additional_information/update', to: 'users#edit_additional_information', as: :edit_additional_information
      end
    end
    resources :roles
    resources :reminders do
      member do
        post '/cancel', to: 'reminders#cancel'
      end
    end
    resources :batches, path: '/batches/:batch_template_name', except: [:index, :create]
    get '/batches', to: 'batches#index', as: :batches_index
    post '/batches/load_batch', to: 'batches#load_batch', as: :load_batch_json
    post '/batches', to: 'batches#create'

    resources :document_templates
    resources :documents do
      collection do
        post '/index-create', to: 'documents#index_create', as: :index_create_document
        get '/multiple-edit', to: 'documents#multiple_edit', as: :multiple_edit
      end
    end
    get '/archives', to: 'archives#index', as: :archives
    get '/archives/:workflow_name/:workflow_id', to: 'archives#show', as: :archive

    get '/recurring_workflows', to: 'recurring_workflows#index', as: :workflows_recurring
    resources :recurring_workflows, path: '/recurring_workflows/:recurring_workflow_name', except: [:index] do
      member do
        post '/stop_recurring', to: 'recurring_workflows#stop_recurring'
        get :trigger_workflow, to: 'recurring_workflows#trigger_workflow'
      end
    end

    resources :workflows, param: :workflow_id, path: '/:workflow_name' do
      member do
        get '/history', to: 'workflows#activities', as: :activities
        post '/archive', to: 'workflows#archive', as: :archive
        post '/reset', to: 'workflows#reset', as: :reset
        get '/section/:section_id', to: 'workflows#show', as: :section
        post '/task/:task_id', to: 'workflows#toggle', as: :task_toggle
        post '/send_reminder/:task_id', to: 'workflows#send_reminder', as: :reminder_task
        post '/stop_reminder/:task_id', to: 'workflows#stop_reminder', as: :stop_reminder
        get '/assign', to: 'workflows#assign', as: :assign
        get '/data-entry', to: 'workflows#data_entry', as: :data_entry
        post '/xero_create_invoice_payable', to: 'workflows#xero_create_invoice_payable', as: :xero_create_invoice_payable
        get :send_email_to_xero, to: 'workflows#send_email_to_xero', as: :send_email_to_xero
        post '/complete_task/:action_id', to: 'workflows#workflow_action_complete', as: :workflow_action_complete
        post '/invoices/reject', to:'invoices#reject', as: :reject_invoice
        post '/invoices/next', to:'invoices#next_invoice', as: :next_invoice
        post '/invoices/prev', to:'invoices#prev_invoice', as: :prev_invoice
        resources :invoices do
          post '/next', to:'invoices#next_show_invoice', as: :next_show_invoice
          post '/prev', to:'invoices#prev_show_invoice', as: :prev_show_invoice
        end
      end
    end

    root to: 'home#index'
  end

  namespace :conductor do
    resources :event_types
    resources :users do
      collection do
        get :export, to: 'users#export'
        post :import, to: 'users#import'
      end
    end
    resources :events do
      collection do
        get :history, to: 'events#activities', as: :activities
      end
      member do
        get '/create-allocations/:type/:count', to: 'events#create_allocations', as: :create_allocations
        post '/reset', to: 'events#reset', as: :reset
      end
    end
    resources :allocations do
      collection do
        get :export, to: 'allocations#export'
        get '/users/:user_id', to: 'allocations#user_allocations', as: :user
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

  devise_scope :user do
    get 'users/password/new', to: 'users/passwords#new', as: 'new_user_password'
    get 'users/additional_information', to: 'users/registrations#additional_information', as: 'additional_information'
  end

  devise_for :users, controllers: { confirmations: 'confirmations', omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations', sessions: 'users/sessions' }, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'sign_up' }

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

  get 'company', to: 'companies#show', as: :company
  get 'company/new', to: 'companies#new', as: :new_company
  post 'company/create', to: 'companies#create', as: :create_company
  get 'company/edit', to: 'companies#edit', as: :edit_company
  patch 'company', to: 'companies#update'

  # Hosted files
  get 'financial-model-course' => redirect('https://excide.s3-ap-southeast-1.amazonaws.com/financial-model-course-info.pdf')

  # Static pages
  get 'faq', to: 'home#faq'
  get 'terms', to: 'home#terms'
  get 'privacy', to: 'home#privacy'
  get 'about-us', to: 'home#about', as: :about
  get 'symphony-xero-automation', to: 'home#symphony-xero-automation', as: :symphony_xero_automation

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
