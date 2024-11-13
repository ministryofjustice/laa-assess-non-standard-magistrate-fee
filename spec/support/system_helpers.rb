module SystemHelpers
  def stub_load_from_app_store(submission)
    return unless submission

    stub_request(:get, "https://appstore.example.com/v1/submissions/#{submission.id}").to_return(lambda do |_|
      {
        status: 200,
        body: NotifyAppStore::MessageBuilder.new(submission: submission.reload, validate: false).message.merge(
          version: 1,
          updated_at: submission.updated_at,
          created_at: submission.created_at,
          last_updated_at: submission.last_updated_at,
          assigned_user_id: submission.assignments.first&.user_id
        ).to_json
      }
    end)
  end
end

RSpec.configuration.include SystemHelpers
