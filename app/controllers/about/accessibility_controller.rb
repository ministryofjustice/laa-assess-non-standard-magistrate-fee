module About
  class AccessibilityController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :skip_authorization

    def index; end
  end
end
