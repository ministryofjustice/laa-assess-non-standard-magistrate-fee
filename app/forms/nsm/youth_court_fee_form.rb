module Nsm
  class YouthCourtFeeForm < BaseAdjustmentForm
    COMMENT_FIELD = 'youth_court_fee_adjustment_comment'.freeze
    LINKED_CLASS = V1::YouthCourtFee

    attribute :remove_youth_court_fee
    attribute :youth_court_fee_adjustment_comment

    def save
      return false unless valid?

      remove_bool = ActiveModel::Type::Boolean.new.cast(remove_youth_court_fee)

      process_field(value: !remove_bool, field: 'include_youth_court_fee')

      true
    end

    private

    def ensure_original_field_value_set(field)
      if selected_record["#{field}_original"].present?
        selected_record.delete("#{field}_original")
        selected_record.delete(self.class::COMMENT_FIELD)
      else
        selected_record["#{field}_original"] ||= selected_record[field]
      end
    end

    def explanation_required?
      remove_youth_court_fee == 'true'
    end

    def adjustment_comment
      youth_court_fee_adjustment_comment
    end

    def selected_record
      @selected_record ||= submission.data
    end

    def data_has_changed?
      remove_youth_court_fee != item.include_youth_court_fee
    end

    def linked
      {
        type: self.class::LINKED_CLASS::LINKED_TYPE
      }
    end
  end
end
