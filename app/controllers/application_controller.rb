# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # These are needed otherwise turbo frames don't render in tests
  helper Turbo::FramesHelper if Rails.env.test?
  helper Turbo::StreamsHelper if Rails.env.test?

  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :check_maintenance_mode
  before_action :authenticate_user!
  before_action :set_security_headers
  before_action :set_default_cookies

  private

  def after_sign_in_path_for(_user)
    root_path
  end

  def set_security_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
  end

  def check_maintenance_mode
    return unless FeatureFlags.maintenance_mode.enabled?

    render file: 'public/maintenance.html', layout: false
  end
end
