module PriorAuthority
  class BaseController < ApplicationController
    layout 'prior_authority'

    private

    def submission_id
      params[:application_id]
    end
  end
end
