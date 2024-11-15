class NotifyEventAppStore < ApplicationJob
  queue_as :default

  def self.perform_now(event:, submission:)
    new.perform(event:, submission:)
  end

  def perform(event:, submission:)
    result = client.create_events(submission.id, events: [event.as_json])
    handle_forbidden_response(event, submission) if result == :forbidden
  end

  private

  def handle_forbidden_response(event, submission)
    data = client.get_submission(submission.id)

    return log_warning(event) if data['events'].find { _1['id'] == event.id }

    raise "Cannot sync event #{event.id} to submission #{submission.id} in App Store: Forbidden"
  end

  def client
    @client ||= AppStoreClient.new
  end

  def log_warning(event)
    Rails.logger.warn "Event sync failed with 403 for #{event.id} but event was already in app store"
  end
end
