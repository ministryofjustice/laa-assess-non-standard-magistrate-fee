class SearchResult
  include NameConstructable
  include SubmissionTagHelper

  def initialize(data)
    @data = data
  end

  delegate :id, to: :submission

  def submission
    @submission ||= Submission.find_by(id: @data[:application_id]) || UpdateSubmission.call(@data.deep_stringify_keys)
  end

  def laa_reference
    submission.data['laa_reference']
  end

  def firm_name
    submission.data['firm_name']
  end

  def client_name
    defendant = submission.data['defendant'] || submission.data['defendants'].find { _1['main'] }
    construct_name(defendant)
  end

  def caseworker
    submission.assignments.first&.display_name || I18n.t('search.unassigned')
  end

  def date_updated
    submission.updated_at.to_fs(:stamp)
  end

  def state_tag
    submission_state_tag(submission)
  end
end
