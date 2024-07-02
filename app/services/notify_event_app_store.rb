class NotifyEventAppStore < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 10

  def perform(event:)
    client = AppStoreClient.new
    client.create_events(event.submission_id, events: [event.as_json])
  end
end
