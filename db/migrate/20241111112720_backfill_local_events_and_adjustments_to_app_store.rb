class BackfillLocalEventsAndAdjustmentsToAppStore < ActiveRecord::Migration[7.2]
  def change
    client = AppStoreClient.new
    Submission.where(state: %i[submitted provider_updated]).find_each do |submission|
      client.adjust(submission)
      client.create_events(submission.id, submission.events)
    end

    # For old pre-RFI NSMs, caseworkers could still conceivably be adding events and
    # adjustments
    Submission.where(application_type: 'crm7', state: :sent_back).find_each do |submission|
      client.adjust(submission)
      client.create_events(submission.id, submission.events)
    end
  end
end
