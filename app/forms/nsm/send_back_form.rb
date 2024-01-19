module Nsm
  class SendBackForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    STATES = [
      FURTHER_INFO = 'further_info'.freeze,
      PROVIDER_REQUESTED = 'provider_requested'.freeze,
    ].freeze

    attribute :state
    attribute :comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :state, inclusion: { in: STATES }
    validates :comment, presence: true, if: -> { state.present? }

    def save
      return false unless valid?

      previous_state = claim.state
      Claim.transaction do
        claim.update!(state:)
        Event::SendBack.build(submission: claim, comment: comment, previous_state: previous_state,
                              current_user: current_user)
        NotifyAppStore.process(submission: claim)
      end

      true
    end
  end
end
