module Users
  class DevAuthController < Devise::SessionsController
    def new
      skip_authorization
      raise ActionController::RoutingError, 'dev authentication not available' unless FeatureFlags.dev_auth.enabled?

      @emails = User.order(last_auth_at: :desc).pluck(:email) << OmniAuth::Strategies::DevAuth::NO_AUTH_EMAIL
    end
  end
end
