class SearchResult
  include NameConstructable
  include SubmissionTagHelper

  def initialize(data)
    @data = data.deep_stringify_keys
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

  def date_updated
    submission.updated_at.to_fs(:stamp)
  end

  def state_tag
    submission_state_tag(submission)
  end

  delegate :application_type, to: :submission

  def application_path
    case submission.application_type
    when 'crm4'
      Rails.application.routes.url_helpers.prior_authority_application_path(submission.id)
    when 'crm7'
      Rails.application.routes.url_helpers.nsm_claim_claim_details_path(submission.id)
    # :nocov:
    else
      false
    end
    # :nocov:

  end
end
