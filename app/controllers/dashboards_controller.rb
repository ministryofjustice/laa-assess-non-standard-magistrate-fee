class DashboardsController < ApplicationController
  before_action :authorize_supervisor

  def show
    payload = {
      resource: { dashboard: ENV.fetch('METABASE_DASHBOARD_ID').to_i },
      params: {},
      exp: Time.now.to_i + (60 * 10) # 10 minute expiration
    }
    token = JWT.encode(payload, ENV.fetch('METABASE_SECRET_KEY'))

    @iframe_url = "#{ENV.fetch('METABASE_SITE_URL')}/embed/dashboard/#{token}#bordered=true&titled=true"
  end

  def authorize_supervisor
    redirect_to root_path unless current_user.supervisor?
  end
end
