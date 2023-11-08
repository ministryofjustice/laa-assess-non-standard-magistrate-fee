class Event
  class Unassignment < Event
    belongs_to :secondary_user, optional: true, class_name: 'User'

    def self.build(claim:, user:, current_user:)
      create(
        claim: claim,
        primary_user: user,
        secondary_user: user == current_user ? nil : current_user,
        claim_version: claim.current_version,
      )
    end
  end
end
