# Can be used in combination with a form string attribute used to hold a date input value.
# Useful in combination with MoJ date picker.
# https://design-patterns.service.justice.gov.uk/components/date-picker/
#
# example:
#  attribute :dob, :string
#  validates :dob, is_a_date: true
#
# Any dates that are unparseable will be left as strings so that the user can
# be shown exactly what they entered in the relevant field alongside the validation message.
#
class IsADateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return true if value.is_a?(Date) || value.blank?

    Date.parse(value)
  rescue Date::Error
    record.errors.add(attribute, :not_a_date)
  end
end
