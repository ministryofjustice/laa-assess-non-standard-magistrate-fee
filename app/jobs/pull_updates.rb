class PullUpdates < ApplicationJob
  # queue :default

  def perform
    last_update = Submission.maximum(:app_store_updated_at) || Time.zone.local(2023, 1, 1)

    json_data = AppStoreClient.new.get_all_submissions(last_update)

    json_data['applications'].each do |record|
      ReceiveApplicationMetadata.new(record).save
    end
  end
end
