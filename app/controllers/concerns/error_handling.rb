module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from Exception do |exception|
      raise unless ENV.fetch('RAILS_ENV', nil) == 'production'

      Sentry.capture_exception(exception) if ENV.fetch('SENTRY_DSN', nil).present?
      Rails.logger.error(exception)
    end
  end
end
