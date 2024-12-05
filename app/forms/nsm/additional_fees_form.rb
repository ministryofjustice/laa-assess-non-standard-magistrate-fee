module Nsm
  class AdditionalFeesForm < ::BaseAdjustmentForm
    class YouthCourtFee < AdditionalFeesForm; end

    LINKED_CLASS = V1::AdditionalFee
  end
end
