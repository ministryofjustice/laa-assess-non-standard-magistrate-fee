class SearchResult
  include NameConstructable
  include SubmissionTagHelper

  def initialize(data)
    @submission = Submission.rehydrate(data)
  end

  attr_reader :submission

  delegate :id, to: :submission

  def laa_reference
    submission.data['laa_reference']
  end

  def firm_name
    submission.data.dig('firm_office', 'name')
  end

  def client_name
    defendant = submission.data['defendant'] || submission.data['defendants'].find { _1['main'] }
    construct_name(defendant)
  end

  def caseworker
    User.find_by(id: submission.assigned_user_id)&.display_name || I18n.t('search.unassigned')
  end

  def date_updated
    submission.app_store_updated_at.to_fs(:stamp)
  end

  def service_name
    I18n.t(submission.data['service_type'], scope: 'prior_authority.service_types')
  end

  def state_tag
    submission_state_tag(submission)
  end

  def risk_name
    I18n.t("nsm.claims.table.risk.#{submission.risk}")
  end

  delegate :application_type, to: :submission

  # assuming all submissions have an application_type as this has to
  # be a valid value (i.e. not blank) - testing it is both arduous and redundant
  def application_path
    case submission.application_type
    when 'crm4'
      Rails.application.routes.url_helpers.prior_authority_application_path(submission.id)
    else
      Rails.application.routes.url_helpers.nsm_claim_claim_details_path(submission.id)
    end
  end
end
