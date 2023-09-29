# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
end
