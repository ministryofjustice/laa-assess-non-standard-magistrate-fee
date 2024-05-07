module About
  class PrivacyController < ApplicationController
    skip_before_action :authenticate_user!

    def index; end
  end
end
