module PriorAuthority
  class ManualAssignmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :comment, :string

    validates :comment, presence: true
  end
end
