class AppStoreSubscriber
  include Rails.application.routes.url_helpers

  def self.subscribe
    new.change_subscription(:create)
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  def self.unsubscribe
    new.change_subscription(:destroy)
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  def change_subscription(action)
    hostname = ENV.fetch('INTERNAL_HOST_NAME', ENV.fetch('HOSTS', nil)&.split(',')&.first)
    return if hostname.blank?

    url = app_store_webhook_url(
      host: hostname,
      protocol: 'http'
    )

    AppStoreClient.new.trigger_subscription(
      { webhook_url: url, subscriber_type: :caseworker },
      action:,
    )
  end
end
