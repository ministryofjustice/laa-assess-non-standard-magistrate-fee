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

      MakeDecisionService.process(submission: claim,
                                  comment: comment,
                                  user_id: current_user.id,
                                  application_state: state)

      true
    end
  end
end
