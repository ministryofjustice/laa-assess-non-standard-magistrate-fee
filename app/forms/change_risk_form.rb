class ChangeRiskForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  RiskLevels = Struct.new(:id, :level)

  attribute :id
  attribute :risk_level
  attribute :explanation
  attribute :current_user

  validates :claim, presence: true
  validates :risk_level, presence: true
  validates :explanation, presence: true

  def save
    return false unless valid?

    previous_risk_level = claim.risk
    Claim.transaction do
      claim.update!(risk: risk_level)
      Event::ChangeRisk.build(claim:, explanation:, previous_risk_level:, current_user:)
    end

    true
  rescue StandardError
    false
  end

  def claim
    Claim.find_by(id:)
  end

  def available_risks
    low_risk = RiskLevels.new('low', 'Low risk')
    medium_risk = RiskLevels.new('medium', 'Medium risk')
    high_risk = RiskLevels.new('high', 'High risk')
    [low_risk, medium_risk, high_risk]
  end
end
