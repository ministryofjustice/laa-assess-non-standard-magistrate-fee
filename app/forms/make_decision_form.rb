class MakeDecisionForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  STATES = [
    GRANT = 'grant'.freeze,
    PART_GRANT = 'part_grant'.freeze,
    REJECT = 'reject'.freeze
  ].freeze

  attribute :id
  attribute :state
  attribute :partial_comment
  attribute :reject_comment
  attribute :current_user

  validates :claim, presence: true
  validates :state, inclusion: { in: STATES }
  validates :partial_comment, presence: true, if: -> { state == PART_GRANT }
  validates :reject_comment, presence: true, if: -> { state == REJECT }

  def save
    return false unless valid?

    previous_state = claim.state
    Claim.transaction do
      claim.update!(state:)
      Event::Decision.build(claim:, comment:, previous_state:, current_user:)
      NotifyAppStore.process(claim:)
    end

    true
  rescue StandardError
    false
  end

  def comment
    case state
    when PART_GRANT
      partial_comment
    when REJECT
      reject_comment
    end
  end

  private

  def claim
    Claim.find_by(id:)
  end
end
