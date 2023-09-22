# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "landing#index"

  get :ping, to: 'healthcheck#ping'

  resources :healthcheck, only: [] do
    collection do
      get :ping
    end
  end
  resources :application_versions, only: [:update]
  resources :landing, only: [:index]
  resources :claims, only: [:index] do
    resource :claim_details, only: [:show]
    resource :adjustments, only: [:show]
    resources :work_items, only: [:index]
    resources :letters_and_calls, only: [:index]
    resources :disbursements, only: [:index]
    resource :supporting_evidences, only: [:show]
  end
  resources :your_claims, only: [:index]
  resources :assessed_claims, only: [:index]
  namespace :about do
    get :privacy
    get :contact
    get :feedback
    get :accessibility
  end
end
