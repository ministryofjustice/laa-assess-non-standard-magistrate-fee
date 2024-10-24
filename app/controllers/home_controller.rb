class HomeController < ApplicationController
  before_action :skip_authorization
end
