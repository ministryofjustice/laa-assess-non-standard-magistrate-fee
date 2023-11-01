# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "landing#index"

  get :ping, to: 'healthcheck#ping'

  devise_for(
    :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks'
    }
  )

  get "users/auth/failure", to: "errors#forbidden"

  devise_scope :user do
    unauthenticated :user do
      root 'users/sessions#new', as: :unauthenticated_root

      if FeatureFlags.dev_auth.enabled?
        get 'dev_auth', to: 'users/dev_auth#new'
      end
    end

    authenticated :user do
      get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
    end
  end

  resources :healthcheck, only: [] do
    collection do
      get :ping
    end
  end

  resources :application_versions, only: [:update]
  resources :landing, only: [:index]
  resources :claims, only: [:new, :index, :destroy] do
    resource :claim_details, only: [:show]
    resource :adjustments, only: [:show]
    namespace :letters_and_calls do
      resource :uplift, only: [:edit, :update], path_names: { edit: '' }
    end
    resources :work_items, only: [:index, :edit, :update], path_names: { edit: '' }
    resources :letters_and_calls, only: [:index, :edit, :update], path_names: { edit: '' }
    resources :disbursements, only: [:index]
    resource :supporting_evidences, only: [:show]
    resource :history, only: [:show, :create]
    resources :send_back, only: [:index]
    resource :change_risk, only: [:edit, :update], path_names: { edit: '' }
    resource :make_decision, only: [:edit, :update], path_names: { edit: '' }
  end

  get 'claims/:claim', to: redirect('claims/%{claim}/claim_details')

  resources :your_claims, only: [:index]
  resources :assessed_claims, only: [:index]

  namespace :about do
    get :privacy
    get :contact
    get :feedback
    get :accessibility
  end
end
