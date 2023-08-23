class PullLatestVersionData < ApplicationJob
  queue :default

  def perform(claim_id)
    claim = Claim.find(claim_id)

    if claim.versions.find_by(version: claim.current_version)
      # data for required version is already here so just skip this
      return
    end

    # something to pull the data and store it in a sensible fashion
  end
end