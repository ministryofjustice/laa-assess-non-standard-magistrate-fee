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

      Claim.transaction do
        update_local_data
        NotifyAppStore.perform_later(submission: claim)
      end

      true
    end

    def update_local_data
      previous_state = claim.state
      claim.data.merge!('status' => SENT_BACK, 'updated_at' => Time.current, 'assessment_comment' => comment)
      claim.update!(state: SENT_BACK)
      claim.assignments.destroy_all
      Nsm::Event::SendBack.build(submission: claim,
                                 comment: comment,
                                 previous_state: previous_state,
                                 current_user: current_user)
    end
  end
end
