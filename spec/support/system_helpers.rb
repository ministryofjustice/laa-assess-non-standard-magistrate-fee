module SystemHelpers
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength
  def stub_app_store_interactions(submission)
    return unless submission

    stub_request(:get, "https://appstore.example.com/v1/submissions/#{submission.id}").to_return(lambda do |_|
      {
        status: 200,
        body: NotifyAppStore::MessageBuilder.new(submission: submission, validate: false).message.merge(
          version: 1,
          updated_at: submission.updated_at,
          created_at: submission.created_at,
          last_updated_at: submission.app_store_updated_at,
          assigned_user_id: submission.assigned_user_id
        ).to_json
      }
    end)

    stub_request(:post, "https://appstore.example.com/v1/submissions/#{submission.id}/events").to_return(lambda do |request|
      data = JSON.parse(request.body)
      data['events'].each do |params|
        event = Event.rehydrate(params.with_indifferent_access, submission.application_type)
        submission.events << event unless submission.events.find { _1.id == event.id }
      end
      { status: 201 }
    end)

    stub_request(:post, "https://appstore.example.com/v1/submissions/#{submission.id}/adjustments").to_return(lambda do |request|
      submission.data = JSON.parse(request.body)['application']
      { status: 201 }
    end)

    stub_request(:put, "https://appstore.example.com/v1/application/#{submission.id}").to_return(lambda do |request|
      data = JSON.parse(request.body)
      submission.data = data['application']
      submission.state = data['application_state']
      submission.app_store_updated_at = DateTime.current
      submission.events = data['events'].map { Event.rehydrate(_1, submission.application_type) }
      { status: 201 }
    end)

    stub_request(:post, "https://appstore.example.com/v1/submissions/#{submission.id}/assignment").to_return(lambda do |request|
      submission.assigned_user_id = JSON.parse(request.body)['caseworker_id']
      { status: 201 }
    end)

    stub_request(:patch, "https://appstore.example.com/v1/submissions/#{submission.id}/metadata").to_return(lambda do |request|
      submission.risk = JSON.parse(request.body)['application_risk']
      { status: 200 }
    end)

    stub_request(:delete,
                 "https://appstore.example.com/v1/submissions/#{submission.id}/assignment").to_return(lambda do |_request|
                                                                                                        submission.assigned_user_id = nil
                                                                                                        { status: 204 }
                                                                                                      end)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Layout/LineLength
end

RSpec.configuration.include SystemHelpers
