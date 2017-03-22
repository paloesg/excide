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

  resources :surveys
  get 'survey/:survey_id/section/:section_position', to: 'surveys#section', as: :survey_section
  get 'survey/complete', to: 'surveys#complete', as: :survey_complete

  resources :segments
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

  get '/robots.txt' => 'home#robots'

  root 'home#index'
end
