Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get 'profile', to: 'profiles#show'
  get 'profile/edit', to: 'profiles#edit', as: :edit_profile
  patch 'profile', to: 'profiles#update'

  root 'home#index'
end
