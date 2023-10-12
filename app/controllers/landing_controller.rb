# frozen_string_literal: true

class LandingController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_security_headers
end
