class SearchFormPresenter
  attr_accessor :service, :current_user

  def initialize(service)
    @service = service
    @current_user = current_user
  end

  def result_headers
    risk_headers = %i[laa_reference firm_name client_name caseworker last_updated risk status_with_assignment]
    return risk_headers if show_risk_filter?

    %i[laa_reference firm_name client_name caseworker last_updated status_with_assignment]
  end

  def show_risk_filter?
    return true if service == 'analytics'

    service != 'crm4'
  end
end
