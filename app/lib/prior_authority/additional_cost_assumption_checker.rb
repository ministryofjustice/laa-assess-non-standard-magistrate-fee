module PriorAuthority
  class AdditionalCostAssumptionChecker
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :time_spent, :float
    attribute :cost_per_hour, :float
    attribute :description, :string

    validates :id, presence: true
    validates :time_spent, numericality: { greater_than: 0, allow_nil: false }
    validates :cost_per_hour, numericality: { greater_than: 0, allow_nil: false }
    validates :description, presence: true
  end
end
