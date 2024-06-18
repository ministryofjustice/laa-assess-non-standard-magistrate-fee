class DashboardsController < ApplicationController
  before_action :authorize_supervisor

  def show
    ids = ENV.fetch('METABASE_DASHBOARD_IDS').split(',')
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

  def authorize_supervisor
    redirect_to root_path if !FeatureFlags.insights.enabled? || !current_user.supervisor?
  end
end
