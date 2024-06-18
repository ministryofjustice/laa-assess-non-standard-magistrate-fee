module About
  class PrivacyController < ApplicationController
    skip_before_action :authenticate_user!

    layout 'assess_a_crime_form'

    def index; end
  end
end
