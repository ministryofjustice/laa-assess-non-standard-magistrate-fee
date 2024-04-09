class SyncController < ApplicationController
  skip_before_action :authenticate_user!

  def sync_all
    PullUpdates.new.perform
    head :ok
  end
end
