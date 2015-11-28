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
  get 'business', to: 'home#business'

  root 'home#index'
end
