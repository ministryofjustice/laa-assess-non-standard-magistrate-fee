class NotifyEventAppStore < ApplicationJob
  queue_as :default

  def self.perform_now(event:)
    new.perform(event:)
  end

  def perform(event:)
    result = client.create_events(event.submission_id, events: [event.as_json])
    handle_forbidden_response(event) if result == :forbidden
  end

  private

  def handle_forbidden_response(event)
    data = client.get_submission(event.submission_id)

    return log_warning(event) if data['events'].find { _1['id'] == event.id }

    raise "Cannot sync event #{event.id} to submission #{event.submission_id} in App Store: Forbidden"
  end

  def client
    @client ||= AppStoreClient.new
  end

  def log_warning(event)
    Rails.logger.warn "Event sync failed with 403 for #{event.id} but event was already in app store"
  end
end
