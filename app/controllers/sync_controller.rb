class SyncController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_app_store!, only: :sync_individual
  skip_before_action :verify_authenticity_token, only: :sync_individual

  def sync_all
    PullUpdates.new.perform
    head :ok
  end

  def sync_individual
    Rails.logger.info("SYNCING SUBMISSION")
    UpdateSubmission.call(params[:data].permit!.to_h)
    head :ok
  end

  def authenticate_app_store!
    head(:unauthorized) unless AppStoreTokenAuthenticator.call(request.headers)
  end
end
