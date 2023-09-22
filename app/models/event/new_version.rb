class Event
  class NewVersion < Event
    def self.build(claim:)
      create(claim: claim, claim_version: claim.current_version)
    end
  end
end
