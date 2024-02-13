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
      @user ||= claim.assigned_user
    end

    def save
      return false unless valid?

      AppStoreService.unassign(claim, comment, current_user)

      true
    end
  end
end
