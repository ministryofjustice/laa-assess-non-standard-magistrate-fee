# frozen_string_literal: true

class LandingController < ApplicationController
  before_action :authenticate_user!
  before_action :set_security_headers
end
