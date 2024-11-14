module PriorAuthority
  class UnassignmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :comment, :string
    attribute :application

    validates :comment, presence: true

    def caseworker_name
      @caseworker_name ||= User.find(application.assigned_user_id).display_name
    end
  end
end
