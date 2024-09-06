class AdjustmentsDependantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    direction = record&.claim&.assessment_direction

    record.errors.add(attribute, :invalid) if value == 'granted' && direction.in?([:mixed, :down])
    # record.errors.add(attribute, :invalid) if value == 'part_grant' && direction.in?([:up, :none])
  end
end
