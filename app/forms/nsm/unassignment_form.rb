module Nsm
  class UnassignmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :comment, presence: true

    def unassignment_user
      user == current_user ? 'assigned' : 'other'
    end

    def user
      @user ||= assignment.user
    end

    def save
      return false unless valid?

      if assignment
        Claim.transaction do
          Event::Unassignment.build(submission: claim,
                                    user: user,
                                    current_user: current_user,
                                    comment: comment)

          assignment.delete
        end
      end

      true
    end

    private

    def assignment
      @assignment ||= claim.assignments.first
    end
  end
end
