module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from Exception do |exception|
      raise unless ENV.fetch('RAILS_ENV', nil) == 'production'

      Sentry.capture_exception(exception) if ENV.fetch('SENTRY_DSN', nil).present?
      Rails.logger.error(exception)
      respond_with_status(:internal_server_error)
    end
  end

  private

  def respond_with_status(status)
    respond_to do |format|
      format.html { render status: }
      format.all  { head status }
    end
  end
end
