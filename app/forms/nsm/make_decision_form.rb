module Nsm
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

      MakeDecisionService.process(submission: claim,
                                  comment: comment,
                                  user_id: current_user.id,
                                  application_state: state)

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
  end
end
