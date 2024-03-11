module PriorAuthority
  class UnassignmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :comment, :string
    attribute :application_id, :string

    validates :comment, presence: true

    def caseworker_name
      @caseworker_name ||= begin
        application = PriorAuthorityApplication.find(application_id)
        application.assignments.first&.display_name
      end
    end
  end
end
