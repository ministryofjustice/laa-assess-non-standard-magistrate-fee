module PriorAuthority
  class DecisionForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :submission
    attribute :current_user
    attribute :pending_decision, :string
    attribute :pending_granted_explanation, :string
    attribute :pending_part_grant_explanation, :string
    attribute :pending_rejected_explanation, :string

    STATES = [
      GRANTED = 'granted'.freeze,
      PART_GRANT = 'part_grant'.freeze,
      REJECTED = 'rejected'.freeze
    ].freeze

    validates :pending_decision, inclusion: { in: STATES }
    validates :pending_rejected_explanation, presence: true, if: -> { pending_decision == REJECTED }
    validates :pending_part_grant_explanation, presence: true, if: -> { pending_decision == PART_GRANT }
    validate :check_adjustments_made_if_part_grant
    validate :not_yet_assessed

    def summary
      @summary ||= BaseViewModel.build(:application_summary, submission)
    end

    def save
      return false unless valid?

      PriorAuthorityApplication.transaction do
        stash(add_draft_decision_event: false)
        previous_state = submission.state

        submission.update!(state: pending_decision)
        Event::Decision.build(submission: submission,
                              comment: explanation,
                              previous_state: previous_state,
                              current_user: current_user)
        NotifyAppStore.process(submission:)
      end

      true
    end

    def stash(add_draft_decision_event: true)
      submission.data.merge!(attributes.except('submission', 'current_user'))
      submission.save!

      return unless add_draft_decision_event

      Event::DraftDecision.build(submission: submission,
                                 comment: explanation,
                                 next_state: pending_decision,
                                 current_user: current_user)
    end

    def explanation
      case pending_decision
      when GRANTED
        pending_granted_explanation
      when PART_GRANT
        pending_part_grant_explanation
      when REJECTED
        pending_rejected_explanation
      end
    end

    def check_adjustments_made_if_part_grant
      return unless pending_decision == PART_GRANT
      return if summary.adjustments_made?

      errors.add(:pending_decision, :no_adjustments)
    end

    def not_yet_assessed
      return unless submission.state.in?(STATES)

      errors.add(:base, :already_assessed)
    end
  end
end
