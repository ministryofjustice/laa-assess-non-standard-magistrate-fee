# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "claims#index"

  get :ping, to: 'healthcheck#ping'
  
  resources :healthcheck, only: [] do
    collection do
      get :ping
    end
  end

  resources :application_versions, only: [:update]
  
  resources :claims, only: [:index] do
    resource :claim_details, only: [:show]
    resource :adjustments, only: [:show]
    resources :work_items, only: [:index]
  end

  get 'claims/:claim', to: redirect('claims/%{claim}/claim_details')

  namespace :about do
    get :privacy
    get :contact
    get :feedback
    get :accessibility
  end
end
