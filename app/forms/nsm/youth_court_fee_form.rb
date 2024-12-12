module Nsm
  class YouthCourtFeeForm < BaseAdjustmentForm
    COMMENT_FIELD = 'youth_court_fee_adjustment_comment'.freeze
    LINKED_CLASS = V1::AdditionalFee

    attribute :remove_youth_court_fee, :boolean
    attribute :youth_court_fee_adjustment_comment

    # UX only requires and explanation for when CW wants to remove fee
    validates :explanation, presence: true, if: :remove_youth_court_fee

    def save
      return false unless valid?

      process_field(value: !remove_youth_court_fee, field: 'include_youth_court_fee')

      true
    end

    private

    def no_change_field
      :remove_youth_court_fee
    end

    def selected_record
      @selected_record ||= submission.data
    end

    def data_has_changed?
      remove_youth_court_fee == item.include_youth_court_fee
    end
  end
end
