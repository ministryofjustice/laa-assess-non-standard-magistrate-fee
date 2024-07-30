module Nsm
  class SendBackForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    FURTHER_INFO = 'further_info'.freeze

    attribute :comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :comment, presence: true

    def save
      return false unless valid?

      previous_state = claim.state
      Claim.transaction do
        claim.data['status'] = FURTHER_INFO
        claim.data['updated_at'] = Time.current
        claim.update!(state: FURTHER_INFO)
        claim.assignments.destroy_all
        Nsm::Event::SendBack.build(submission: claim, comment: comment, previous_state: previous_state,
                                   current_user: current_user)
        NotifyAppStore.perform_later(submission: claim)
      end

      true
    end
  end
end
