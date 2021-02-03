Rails.application.routes.draw do
  root to: 'home#index'

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

  # Slack callback path
  get '/oauth/authorization', to: 'slack#callback'
  delete '/disconnect_from_slack', to: 'slack#disconnect_from_slack', as: :disconnect_from_slack

  get '/connect_to_xero', to: 'xero_sessions#connect_to_xero', as: :connect_to_xero
  get '/xero_callback_and_update', to: 'xero_sessions#xero_callback_and_update', as: :xero_callback_and_update
  post '/update_contacts_from_xero', to: 'xero_sessions#update_contacts_from_xero', as: :update_contacts_from_xero
  post '/update_line_items_from_xero', to: 'xero_sessions#update_line_items_from_xero', as: :update_line_items_from_xero
  post '/update_tracking_categories_from_xero', to: 'xero_sessions#update_tracking_categories_from_xero', as: :update_tracking_categories_from_xero
  delete '/disconnect_from_xero', to: 'xero_sessions#disconnect_from_xero', as: :disconnect_from_xero
  patch '/change_company', to: 'home#change_company', as: :change_company

  namespace :symphony do
    root to: 'home#index'

    get '/search', to: 'home#search'
    get '/xero_line_items', to: 'xero_line_items#show'
    post '/add_tasks_to_timesheet', to: 'home#add_tasks_to_timesheet'

    resources :survey_templates, param: :survey_template_slug, except: [:destroy]
    delete '/survey_templates/:survey_template_slug/destroy_survey_section', to: 'survey_templates#destroy_survey_section', as: :destroy_survey_section

    # get '/plan', to: 'companies#plan'
    scope '/checkout' do
      post 'create', to: 'checkout#create', as: :checkout_create
      get 'cancel', to: 'checkout#cancel', as: :checkout_cancel
      get 'success', to: 'checkout#success', as: :checkout_success
    end

    resources :templates, param: :template_slug
    delete '/templates/:template_slug/destroy_section', to: 'templates#destroy_section', as: :destroy_section

    resources :clients do
      member do
        post '/xero_create', to: 'clients#xero_create', as: :xero_create
      end
    end
    resources :users do
      member do
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

    #TODO: Remove recurring workflow after recurring templates are working
    get '/recurring_workflows', to: 'recurring_workflows#index', as: :workflows_recurring
    resources :recurring_workflows, path: '/recurring_workflows/:recurring_workflow_name', except: [:index] do
      member do
        post '/stop_recurring', to: 'recurring_workflows#stop_recurring'
        get :trigger_workflow, to: 'recurring_workflows#trigger_workflow'
      end
    end

    patch 'workflow_actions/update/:id', to: 'workflow_actions#update', as: :workflow_action

    resources :workflows, param: :workflow_id, path: '/:workflow_name' do
      member do
        post '/archive', to: 'workflows#archive', as: :archive
        post '/reset', to: 'workflows#reset', as: :reset
        get '/section/:section_id', to: 'workflows#show', as: :section
        post '/task/:task_id', to: 'workflows#toggle', as: :task_toggle
        post '/send_reminder/:task_id', to: 'workflows#send_reminder', as: :reminder_task
        post '/stop_reminder/:task_id', to: 'workflows#stop_reminder', as: :stop_reminder
        get '/assign', to: 'workflows#assign', as: :assign
        get '/data-entry', to: 'workflows#data_entry', as: :data_entry
        post '/xero_create_invoice', to: 'workflows#xero_create_invoice', as: :xero_create_invoice
        get :send_email_to_xero, to: 'workflows#send_email_to_xero', as: :send_email_to_xero
        post '/complete_task/:action_id', to: 'workflows#workflow_action_complete', as: :workflow_action_complete
        post '/invoices/reject', to:'invoices#reject', as: :reject_invoice
        post '/invoices/next', to:'invoices#next_invoice', as: :next_invoice
        post '/invoices/prev', to:'invoices#prev_invoice', as: :prev_invoice
        post '/xero_details', to:'invoices#get_xero_details_json', as: :get_xero_details_json
        post '/get_textract', to:'invoices#get_document_analysis', as: :get_textract_invoice
        resources :invoices do
          post '/next', to:'invoices#next_show_invoice', as: :next_show_invoice
          post '/prev', to:'invoices#prev_show_invoice', as: :prev_show_invoice
        end
        resources :surveys
      end
    end
  end

  namespace :motif do
    root to: 'home#index'
    patch '/change_outlet', to: 'home#change_outlet', as: :change_outlet
    resources :documents do
      patch '/update_tags', to:'documents#update_tags'
    end
    resources :folders do
      patch '/update_tags', to:'folders#update_tags'
    end
    resources :permissions
    resources :companies
    resources :templates, param: :template_slug
    resources :workflows, except: :show do
      post '/task/:task_id', to: 'workflows#toggle', as: :task_toggle
      post '/upload_documents', to: 'workflows#upload_documents', as: :upload_documents
      get '/wfa/:wfa_id/notify_franchisor', to: 'workflows#notify_franchisor', as: :notify_franchisor
    end
    resources :outlets do
      resources :workflows, only: :show do
        post '/next', to:'workflows#next_workflow', as: :next_workflow
        post '/prev', to:'workflows#prev_workflow', as: :prev_workflow
      end
      resources :notes
      get "/members", to: 'outlets#members', as: :members
      get "/assigned_tasks", to: 'outlets#assigned_tasks', as: :assigned_tasks
      get "/edit_franchisee_settings", to: 'outlets#edit_franchisee_setting', as: :edit_franchisee_setting
    end
    resources :users
    get '/communication_hub', to: 'notes#communication_hub', as: :communication_hub
    post '/add-roles', to: 'users#add_role', as: :add_role
    get '/financial-performance', to: 'home#financial_performance'
    get '/edit-report', to: 'home#edit_report'
  end

  namespace :overture do
    root to: 'home#index'
    resources :companies
    resources :investments
    resources :permissions
    resources :profiles do
      get '/state-interest', to: 'profiles#state_interest', as: :state_interest
    end
    resources :contacts do
      scope module: 'contacts' do
        resources :notes
      end
    end
    resources :contact_statuses
    resources :documents do
      member do
        post 'toggle'
      end
    end
    resources :folders do
      member do
        post 'toggle'
      end
    end
    resources :topics do
      scope module: 'topics' do
        resources :notes
      end
    end
    resources :users
    get '/financial_performance', to: 'home#financial_performance'
    get '/capitalization_table', to: 'home#capitalization_table'
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
        post :import, to: 'events#import'
        get :edit_tags, to: 'events#edit_tags'
        patch :create_tags, to:'events#create_tags'
        patch :update_tags, to:'events#update_tags'
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
    get 'users/password/edit', to: 'users/passwords#edit', as: 'edit_user_password'
    get 'users/additional_information', to: 'users/registrations#additional_information', as: 'additional_information'
  end

  devise_for :users, controllers: { confirmations: 'confirmations', registrations: 'users/registrations', sessions: 'users/sessions' }, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'sign_up/:product' }

  # Integrated with Devise
  notify_to :users, with_devise: :users

  resources :responses

  get 'company', to: 'companies#show', as: :company
  get 'company/new', to: 'companies#new', as: :new_company
  post 'company/create', to: 'companies#create', as: :create_company
  get 'company/edit', to: 'companies#edit', as: :edit_company
  get 'company/billing', to: 'companies#billing', as: :billing_company
  get 'company/integration', to: 'companies#integration', as: :integration_company
  patch 'company', to: 'companies#update'

  # Static pages
  get 'terms', to: 'symphony/home#terms'
  get 'privacy', to: 'symphony/home#privacy'

  # Stripe event path for webhook
  mount StripeEvent::Engine, at: '/stripe/webhook' # provide a custom path
end
