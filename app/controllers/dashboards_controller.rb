class DashboardsController < ApplicationController
  before_action :authorize_supervisor

  layout 'dashboard'

  def show
    @page_title = t(".title.#{@service}")
    generate_dashboards(service)
  end

  def generate_dashboards(service)
    ids = []
    if service == 'prior_authority'
      ids = ENV.fetch('METABASE_PA_DASHBOARD_IDS').split(',')
    elsif service == 'nsm'
      ids = ENV.fetch('METABASE_NSM_DASHBOARD_IDS').split(',')
    end

    @iframe_urls = ids.map do |id|
      payload = {
        resource: { dashboard: id.to_i },
        params: {},
        exp: Time.now.to_i + (60 * 60) # After an hour, using in-dashboard widgets will stop working
      }
      token = JWT.encode(payload, ENV.fetch('METABASE_SECRET_KEY'))

      "#{ENV.fetch('METABASE_SITE_URL')}/embed/dashboard/#{token}#bordered=true&titled=true"
    end
  end

  def service
    @service ||= params.fetch(:service, 'prior_authority')
  end

  def authorize_supervisor
    redirect_to root_path if !FeatureFlags.insights.enabled? || !current_user.supervisor?
  end
end
