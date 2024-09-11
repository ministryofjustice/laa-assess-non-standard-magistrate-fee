module Nsm
  class AdjustmentsController < Nsm::BaseController
    def destroy
      Nsm::AllAdjustmentsDeleter.new(params, current_user).call
    end
  end
end
