class AdjustmentsDependantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    direction = record&.claim&.assessment_direction

    record.errors.add(attribute, :'invalid.granted_with_reductions') if value == Claim::GRANTED && direction.in?([:mixed, :down])
    record.errors.add(attribute, :'invalid.part_granted_without_changes') if value == Claim::PART_GRANT && direction == :none
    record.errors.add(attribute, :'invalid.part_granted_with_increases') if value == Claim::PART_GRANT && direction == :up
  end
end
