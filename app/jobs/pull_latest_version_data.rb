class PullLatestVersionData < ApplicationJob
  queue :default

  def perform(claim_id)
    claim = Claim.find(claim_id)

    if claim.versions.find_by(version: claim.current_version)
      # data for required version is already here so just skip this
      return
    end

    # something to pull the data and app store and create new version

    # reset any data confirmations where data has changed

    # create chnage log since previous version??? or should this be done in provider or app store?
  end
end