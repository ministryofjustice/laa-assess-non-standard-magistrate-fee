class SearchFormPresenter
  attr_accessor :service, :current_user

  def initialize(service, current_user)
    @service = service
    @current_user = current_user
  end

  def result_headers
    headers = %i[laa_reference firm_name client_name caseworker last_updated status_with_assignment]
    headers << :risk if show_risk_filter?
    headers
  end

  def show_risk_filter?
    return true if current_user.supervisor? && service == 'analytics'

    service != 'crm4'
  end
end
