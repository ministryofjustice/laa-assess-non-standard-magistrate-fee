class PullLatestVersionData < ApplicationJob
  # queue :default

  def perform(submission)
    # data for required version is already here
    return if submission.data.present?

    json_data = AppStoreClient.new.get_submission(submission.id)

    PopulateSubmissionDetails.call(submission, json_data)
  end
end
