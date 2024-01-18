module Nsm
  class BaseAdjustmentForm < ::BaseAdjustmentForm
    attribute :claim
    validates :submission, presence: true

    # Used by the superclass
    def submission
      claim
    end
  end
end
