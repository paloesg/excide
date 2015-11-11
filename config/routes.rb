Rails.application.routes.draw do
  devise_for :users
  resources :profiles
  resources :users

  get '/auth/:provider/callback', to: 'sessions#create'

  root 'home#index'
end
