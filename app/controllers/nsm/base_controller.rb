module Nsm
  class BaseController < ApplicationController
    layout 'nsm'

    private

    def submission_id
      params[:claim_id]
    end
  end
end
