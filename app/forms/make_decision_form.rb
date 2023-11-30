class MakeDecisionForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  STATES = [
    GRANTED = 'granted'.freeze,
    PART_GRANT = 'part_grant'.freeze,
    REJECTED = 'rejected'.freeze
  ].freeze

  attribute :state
  attribute :partial_comment
  attribute :reject_comment
  attribute :current_user
  attribute :claim

  validates :claim, presence: true
  validates :state, inclusion: { in: STATES }
  validates :partial_comment, presence: true, if: -> { state == PART_GRANT }
  validates :reject_comment, presence: true, if: -> { state == REJECTED }

  def save
    return false unless valid?

    previous_state = claim.state
    Claim.transaction do
      claim.update!(state:)
      Event::Decision.build(claim:, comment:, previous_state:, current_user:)
      NotifyAppStore.process(claim:, email_content:)
    end

    true
  end

  def comment
    case state
    when PART_GRANT
      partial_comment
    when REJECTED
      reject_comment
    end
  end

  def email_content
    case state
    when GRANTED
      FeedbackMessages::GrantedFeedback.new(claim)
    when PART_GRANT
      FeedbackMessages::PartGrantedFeedback.new(claim)
    when REJECTED
      FeedbackMessages::RejectedFeedback.new(claim)
    end
  end
end
