# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :check_maintenance_mode
  before_action :authenticate_user!
  before_action :set_security_headers
  before_action :set_default_cookies
  before_action :set_referrer
  before_action :log_access

  private

  def after_sign_in_path_for(_user)
    root_path
  end

  def set_security_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
  end

  def check_maintenance_mode
    return unless ENV.fetch('MAINTENANCE_MODE', 'false') == 'true'

    render file: 'public/maintenance.html', layout: false
  end

  def set_referrer
    referrer = request.env['HTTP_REFERER']
    @referrer = referrer if referrer && URI(referrer).scheme != 'javascript'
  end

  def log_access
    return unless signed_in? && submission_id.present?

    current_user.access_logs.create!(
      path: request.path,
      controller: controller_name,
      action: action_name,
      submission_id: submission_id,
      secondary_id: secondary_id,
    )
  end

  def submission_id
    nil
  end

  def secondary_id
    params[:id]
  end
end
