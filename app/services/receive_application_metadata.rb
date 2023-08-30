class ReceiveApplicationMetadata
  attr_reader :claim

  delegate :errors, to: :claim

  def initialize(claim_id)
    @claim = Claim.find_or_initialize_by(id: claim_id)
  end

  def save(params, state)
    claim.assign_attributes(params)
    # set default if this is a new record
    claim.received_on ||= Time.zone.today
    # TODO: think if state should be allow to be updated in the future
    claim.state ||= state

    if claim.save
      if claim.saved_change_to_current_version?
        # we don't need to invalidate as everything is tied to current_version
        PullLatestVersionData.perform_later(claim)
      end

      true
    else
      false
    end
  end
end
