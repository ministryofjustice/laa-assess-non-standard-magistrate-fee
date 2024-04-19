class AppStoreSubscriber
  include Rails.application.routes.url_helpers

  def self.call
    new.subscribe
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  def subscribe
    return if ENV['HOSTS'].blank?

    url = app_store_webhook_url(
      host: ENV.fetch('HOSTS', nil),
      protocol: ENV.fetch('PROTOCOL', 'https')
    )

    AppStoreClient.new.create_subscription(
      { webhook_url: url, subscriber_type: :caseworker }
    )
  end
end
