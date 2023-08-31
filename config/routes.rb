# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :healthcheck, only: [] do
    collection do
      get :ping
    end
  end
  resources :application_versions, only: [:update]
  resources :claims, only: [:index, :show]
end
