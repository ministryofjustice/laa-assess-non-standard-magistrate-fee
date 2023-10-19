class LettersCallsForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :id
  attribute :type
  attribute :uplift
  attribute :count

  # TODO: implement in next PR
  # validates :claim, presence: true
  # validates :type, inclusion: { in: %w[letters calls] }
  # attribute :uplift, include: { in: %w[yes no] }
  # validates :count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # def save
  #   return false unless valid?

  #   Event::Note.build(claim:, note:, current_user:)
  #   true
  # rescue StandardError
  #   false
  # end

  # def claim
  #   Claim.find_by(id:)
  # end
end
