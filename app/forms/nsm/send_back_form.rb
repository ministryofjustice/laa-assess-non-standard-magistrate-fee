module Nsm
  class SendBackForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    SENT_BACK = 'sent_back'.freeze

    attribute :comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :comment, presence: true

    def save
      return false unless valid?

      previous_state = claim.state
      Claim.transaction do
        claim.data.merge!('status' => SENT_BACK, 'updated_at' => Time.current)
        claim.update!(state: SENT_BACK)
        claim.assignments.destroy_all
        Nsm::Event::SendBack.build(submission: claim, comment: comment, previous_state: previous_state,
                                   current_user: current_user)
        NotifyAppStore.perform_later(submission: claim)
      end

      true
    end
  end
end
