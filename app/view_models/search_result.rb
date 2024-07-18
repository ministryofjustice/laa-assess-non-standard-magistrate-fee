class SearchResult
  include NameConstructable
  include SubmissionTagHelper

  def initialize(view_data, raw_data)
    @view_data = view_data.deep_stringify_keys
    @data = raw_data.deep_stringify_keys
  end

  delegate :id, to: :submission

  def submission
    @submission ||= Submission.find_by(id: @data['application_id']) || UpdateSubmission.call(@data)
  end

  def laa_reference
    @data.dig('application', 'laa_reference')
  end

  def firm_name
    @data.dig('application', 'firm_office', 'name')
  end

  def client_name
    defendant = @data.dig('application', 'defendant') || @data.dig('application', 'defendants').find { _1['main'] }
    construct_name(defendant)
  end

  def caseworker
    submission.assignments.first&.display_name || I18n.t('search.unassigned')
  end

  def last_updated
    @view_data['last_updated'].to_time.to_fs(:stamp)
  end

  def state_tag
    submission_state_tag(submission)
  end
end
