# frozen_string_literal: true

class LandingController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_security_headers
  before_action :redirect_if_authenticated

  def redirect_if_authenticated
    if user_signed_in?
      redirect_to claims_path
    end
  end
end
