module Nsm
  class AdditionalFeesForm < ::BaseAdjustmentForm
    class YouthCourtFeeForm < AdditionalFeesForm; end

    LINKED_CLASS = V1::AdditionalFee
  end
end
