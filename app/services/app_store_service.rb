class AppStoreService
  class << self
    def list(params)
      data = AppStore::HttpClient.new.list_submissions(params)
      [data['applications'].map { build_submission(_1) }, data['total']]
    end

    def get(submission_id)
      data = AppStore::HttpClient.new.get_submission(submission_id)
      build_submission(data)
    end

    def assign(user_id, application_type)
      data = AppStore::HttpClient.new.assign_submission(user_id:, application_type:)
      build_submission(data) if data
    end

    def update(submission)
      AppStore::HttpClient.new.update_submission(submission.id,
                                                 AppStore::PayloadBuilder.new(submission:))
    end

    def unassign(submission, comment)
      AppStore::HttpClient.new.unassign_submission(submission.id, comment:)
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
