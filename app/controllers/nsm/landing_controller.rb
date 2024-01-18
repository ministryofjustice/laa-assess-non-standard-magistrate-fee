module Nsm
  class LandingController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :set_security_headers
    before_action :redirect_if_authenticated

    def redirect_if_authenticated
      return unless user_signed_in?

      redirect_to nsm_claims_path
    end
  end
end
