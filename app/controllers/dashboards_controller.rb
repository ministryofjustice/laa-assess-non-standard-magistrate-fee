class DashboardsController < ApplicationController
  before_action :authorize_supervisor

  layout 'dashboard'

  def show
    @current_tab ||= params.fetch(:current_tab, 'overview')
    generate_dashboards(service)
  end

  def generate_dashboards(service)
    overview_ids = get_overview_ids(service)
    @iframe_urls = generate_metabase_urls(overview_ids)
    autogrant_ids = ENV.fetch('METABASE_PA_AUTOGRANT_DASHBOARD_IDS')&.split(',') || []
    @autogrant_urls = generate_metabase_urls(autogrant_ids)
  end

  def service
    param = params.fetch(:service, 'prior_authority')
    @service ||= !FeatureFlags.nsm_insights.enabled? && param == 'nsm' ? 'prior_authority' : param
  end

  def authorize_supervisor
    redirect_to root_path if !FeatureFlags.insights.enabled? || !current_user.supervisor?
  end

  private

  def get_overview_ids(service)
    if service == 'prior_authority'
      ids = ENV.fetch('METABASE_PA_DASHBOARD_IDS')&.split(',')
    elsif service == 'nsm'
      ids = ENV.fetch('METABASE_NSM_DASHBOARD_IDS')&.split(',')
    end
    ids || []
  end

  def generate_metabase_urls(ids)
    ids.map do |id|
      payload = {
        resource: { dashboard: id.to_i },
        params: {},
        exp: Time.now.to_i + (60 * 60) # After an hour, using in-dashboard widgets will stop working
      }
      token = JWT.encode(payload, ENV.fetch('METABASE_SECRET_KEY'))

      "#{ENV.fetch('METABASE_SITE_URL')}/embed/dashboard/#{token}#bordered=true&titled=true"
    end
  end
end
