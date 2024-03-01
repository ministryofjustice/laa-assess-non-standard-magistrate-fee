module PriorAuthority
  class BaseAdjustmentForm < ::BaseAdjustmentForm
    validates :submission, presence: true
  end
end
