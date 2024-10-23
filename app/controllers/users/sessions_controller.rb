module Users
  class SessionsController < Devise::SessionsController
    before_action :skip_authorization
  end
end
