# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://web.archive.org/web/20180709235757/https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_WEB_UI_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_WEB_UI_PASSWORD"]))
  end
  mount Sidekiq::Web => "/sidekiq"

  root "home#index"

  get :ping, to: 'healthcheck#ping'

  devise_for(
    :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks'
    }
  )

  get "users/auth/failure", to: "errors#forbidden"

  devise_scope :user do
    if FeatureFlags.dev_auth.enabled?
      get "dev_auth", to: "users/dev_auth#new", as: :new_user_session
    else
      get 'unauthorized', to: 'errors#forbidden', as: :new_user_session
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

  namespace :nsm do
    root to: "claims#index"
    resources :claims, only: [:new, :index] do
      resource :claim_details, only: [:show]
      resource :adjustments, only: [:show]
      namespace :letters_and_calls do
        resource :uplift, only: [:edit, :update], path_names: { edit: '' }
      end
      namespace :work_items do
        resource :uplift, only: [:edit, :update], path_names: { edit: '' }
      end
      resources :work_items, only: [:index, :show, :edit, :update]
      resources :letters_and_calls, only: [:index, :show, :edit, :update], constraints: { id: /(letters|calls)/ }
      resources :disbursements, only: [:index, :show, :edit, :update]
      resource :supporting_evidences, only: [:show] do
        resources :downloads, only: :show
      end
      resource :history, only: [:show, :create]
      resource :change_risk, only: [:edit, :update], path_names: { edit: '' }
      resource :make_decision, only: [:edit, :update], path_names: { edit: '' }
      resource :send_back, only: [:edit, :update], path_names: { edit: '' }
      resource :unassignment, only: [:edit, :update], path_names: { edit: '' }
    end

    get 'claims/:claim', to: redirect('claims/%{claim}/claim_details')

    resources :your_claims, only: [:index]
    resources :assessed_claims, only: [:index]
  end

  namespace :about do
    resources :feedback, only: [:index, :create]
    resources :cookies, only: [:index, :create]
    get :update_cookies, to: 'cookies#update_cookies'
    get :privacy
    get :accessibility
  end

  namespace :prior_authority do
    root to: "applications#your"
    resources :applications, only: [:new, :show] do
      collection do
        get :your
        get :open
        get :assessed
      end

      resources :adjustments, only: :index
      resources :related_applications, only: :index
      resources :service_costs, only: [:edit, :update]
      resources :travel_costs, only: [:edit, :update]
      resources :additional_costs, only: [:edit, :update]
      resources :manual_assignments, only: %i[new create]
      resources :unassignments, only: %i[new create]
    end
    resources :auto_assignments, only: [:create]
    resources :downloads, only: :show
  end
end
