module Nsm
  class BaseAdjustmentForm < ::BaseAdjustmentForm
    attribute :claim
    validates :crime_application, presence: true

    # Used by the superclass
    def crime_application
      claim
    end
  end
end
