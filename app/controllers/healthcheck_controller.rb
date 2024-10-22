# frozen_string_literal: true

class HealthcheckController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_security_headers
  before_action :skip_authorization

  def ping
    render json: build_args
  end

  private

  def build_args
    {
      branch_name: ENV.fetch('APP_BRANCH_NAME', nil),
      build_date: ENV.fetch('APP_BUILD_DATE', nil),
      build_tag: ENV.fetch('APP_BUILD_TAG', nil),
      commit_id: ENV.fetch('APP_GIT_COMMIT', nil)
    }
  end
end
