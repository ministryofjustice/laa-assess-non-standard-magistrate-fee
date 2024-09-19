module Nsm
  class DeleteAdjustmentsForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :comment, :string

    validates :comment, presence: true, allow_blank: false
  end
end
