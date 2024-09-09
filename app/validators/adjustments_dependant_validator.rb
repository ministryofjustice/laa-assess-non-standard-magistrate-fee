class AdjustmentsDependantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    direction = record&.claim&.assessment_direction

    if value == Claim::GRANTED
      validate_granted(record, attribute, direction)
    elsif value == Claim::PART_GRANT
      validate_part_grant(record, attribute, direction)
    end
  end

  private

  def validate_granted(record, attribute, direction)
    record.errors.add(attribute, :'invalid.granted_with_reductions') if direction.in?([:mixed, :down])
  end

  def validate_part_grant(record, attribute, direction)
    record.errors.add(attribute, :'invalid.part_granted_without_changes') if direction == :none
    record.errors.add(attribute, :'invalid.part_granted_with_increases') if direction == :up
  end
end
