module PriorAuthority
  class StaticPagesController < PriorAuthority::BaseController
    skip_before_action :authenticate_user!, only: :landing
    def landing; end
  end
end
