class ReceiveApplicationMetadata
  attr_reader :claim

  delegate :errors, to: :claim

  def initialize(claim_id)
    @claim = Claim.find_or_initialize_by(id: claim_id)
  end

  def save(params)
    claim.assign_attributes(params)
    # set default if this is a new record
    claim.received_on ||= Time.zone.today

    # as the provider can't resubmit let just do this as simple as possible
    # and avoid unnessessary pulls
    return unless claim.save

    PullLatestVersionData.perform_later(claim)
  end
end
