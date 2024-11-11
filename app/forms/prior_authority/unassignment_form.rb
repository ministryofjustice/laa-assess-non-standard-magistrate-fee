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
        application = PriorAuthorityApplication.load_from_app_store(application_id)
        User.find(application.assigned_user_id).display_name
      end
    end
  end
end
