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
    validate :check_adjustments_made
    validate :not_yet_assessed

    def summary
      @summary ||= BaseViewModel.build(:application_summary, submission)
    end

    def save
      return false unless valid?

      submission.with_lock do
        change_data_and_notify_app_store
      end

      true
    end

    def change_data_and_notify_app_store
      stash(add_draft_decision_event: false)
      previous_state = submission.state

      submission.data.merge!('status' => pending_decision, 'updated_at' => Time.current)
      submission.update!(state: pending_decision)
      ::Event::Decision.build(submission: submission,
                              comment: explanation,
                              previous_state: previous_state,
                              current_user: current_user)

      NotifyAppStore.perform_later(submission:)
    end

    def stash(add_draft_decision_event: true)
      submission.data.merge!(attributes.except('submission', 'current_user').merge('assessment_comment' => explanation))
      submission.save!

      return unless add_draft_decision_event

      ::Event::DraftDecision.build(submission: submission,
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

    def check_adjustments_made
      if pending_decision == PART_GRANT
        errors.add(:pending_decision, :no_adjustments) unless summary.adjustments_made?
      elsif summary.adjustments_made?
        errors.add(:pending_decision, :"adjustments_when_#{pending_decision}")
      end
    end

    def not_yet_assessed
      return if submission.state.in?(PriorAuthorityApplication::ASSESSABLE_STATES)

      errors.add(:base, :already_assessed)
    end
  end
end
