class PullUpdates < ApplicationJob
  # queue :default

  def perform
    last_update = Submission.maximum(:app_store_updated_at) || Time.zone.local(2023, 1, 1)

    json_data = HttpPuller.new.get_all(last_update)

    json_data['applications'].each do |record|
      save(record['application_id'], convert_params(record))
    end
  end

  private

  def convert_params(record)
    {
      state: record['application_state'],
      risk: record['application_risk'],
      current_version: record['version'],
      app_store_updated_at: record['updated_at'],
      application_type: record['application_type'],
    }
  end

  def save(submission_id, params)
    receiver = ReceiveApplicationMetadata.new(submission_id)

    receiver.save(params)
  end
end
