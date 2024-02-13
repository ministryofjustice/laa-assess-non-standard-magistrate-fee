class AppStoreService
  class << self
    def list(params)
      data = AppStore::HttpClient.list_submissions(params)
      [data['applications'].map { build_submission(_1) }, data['total']]
    end

    def get(submission_id)
      data = AppStore::HttpClient.get_submission(submission_id)
      build_submission(data)
    end

    def assign(user_id, application_type)
      data = AppStore::HttpClient.assign_submission(user_id:, application_type:)
      build_submission(data) if data
    end

    def adjust(submission, metadata = {})
      AppStore::HttpClient.adjust_submission(submission.id,
                                             AppStore::PayloadBuilder.new(submission:, metadata:))
    end

    def unassign(submission, comment, user)
      AppStore::HttpClient.unassign_submission(submission.id, comment: comment, user_id: user.id)
    end

    def change_risk(submission, comment:, user_id:, application_risk:)
      AppStore::HttpClient.change_risk(submission.id, comment:, user_id:, application_risk:)
    end

    def create_note(submission, note:, user_id:)
      AppStore::HttpClient.create_note(submission.id, note:, user_id:)
    end

    def change_state(submission, comment:, user_id:, application_state:)
      AppStore::HttpClient.change_state(submission.id, comment:, user_id:, application_state:)
    end

    private

    def build_submission(data)
      klass = data['application_type'] == 'crm7' ? Claim : PriorAuthorityApplication
      klass.new(submission_attributes(data))
    end

    def submission_attributes(data)
      { id: data['application_id'],
        state: data['application_state'],
        risk: data['application_risk'],
        current_version: data['version'],
        updated_at: data['updated_at'],
        application_type: data['application_type'],
        events: data['events'].map { Event.hydrate(_1) },
        json_schema_version: data['json_schema_version'],
        data: data['application'],
        created_at: data['created_at'],
        assigned_user: assigned_user(data) }
    end

    def assigned_user(data)
      return if data['assigned_user_id'].blank?

      User.find(data['assigned_user_id'])
    end
  end
end
