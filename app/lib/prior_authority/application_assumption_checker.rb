module PriorAuthority
  class ApplicationAssumptionChecker
    include ActiveModel::Model
    include ActiveModel::Attributes

    COURT_TYPES = %w[central_criminal_court other].freeze
    SERVICE_TYPES = %w[pathologist_report other].freeze

    attribute :laa_reference, :string
    attribute :firm_name, :string
    attribute :client_name, :string
    attribute :additional_costs, array: true
    attribute :court_type, :string
    attribute :service_type, :string

    validates :laa_reference, presence: true
    validates :firm_name, presence: true
    validates :client_name, presence: true
    validate :additional_costs_valid
    validates :court_type, inclusion: { in: COURT_TYPES, allow_nil: false }
    validates :service_type, inclusion: { in: SERVICE_TYPES, allow_nil: false }

    def additional_costs_valid
      checkers = additional_costs.map { AdditionalCostAssumptionChecker.new(_1) }
      return if checkers.all?(&:valid?)

      errors.add(:additional_costs, checkers.reject(&:valid?).map { _1.errors.full_messages }.compact.join("\n"))
    end
  end
end
