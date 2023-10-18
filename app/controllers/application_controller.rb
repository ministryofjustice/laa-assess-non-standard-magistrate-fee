# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include ApplicationHelper
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :authenticate_user!
  before_action :set_security_headers

  private

  def after_sign_in_path_for(_user)
    claims_path
  end

  def set_security_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
  end
end
