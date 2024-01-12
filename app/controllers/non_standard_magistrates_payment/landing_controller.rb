module NonStandardMagistratesPayment
  class LandingController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :set_security_headers
    before_action :redirect_if_authenticated

    def redirect_if_authenticated
      return unless user_signed_in?

      redirect_to non_standard_magistrates_payment_claims_path
    end
  end
end
