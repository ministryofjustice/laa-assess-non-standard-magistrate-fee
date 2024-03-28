module Nsm
  class BaseAdjustmentForm < ::BaseAdjustmentForm
    attribute :claim
    validates :submission, presence: true

    validates :explanation, presence: true, if: :explanation_required?

    # Used by the superclass
    def submission
      claim
    end
  end
end
