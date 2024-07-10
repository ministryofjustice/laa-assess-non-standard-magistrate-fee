class AppStoreSubscriber
  include Rails.application.routes.url_helpers

  def self.call
    new.subscribe
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  def subscribe
    hostname = ENV.fetch('INTERNAL_HOST_NAME', ENV.fetch('HOSTS', nil)&.split(',')&.first)
    return if hostname.blank?

    url = app_store_webhook_url(
      host: hostname,
      protocol: 'http'
    )

    AppStoreClient.new.create_subscription(
      { webhook_url: url, subscriber_type: :caseworker }
    )
  end
end
