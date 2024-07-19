module Nsm
  class BaseController < ApplicationController
    layout 'nsm'

    def remember_page(scope, tab)
      if params[:page]
        session["#{scope}_tab"] = 'work_items'
        session["#{scope}_page"] = params[:page]
      elsif session["#{scope}_tab"] == 'work_items'
        params[:page] = session["#{scope}_page"]
      else
        session["#{scope}_tab"] = nil
        session["#{scope}_page"] = nil
      end
      if tab == session["location"]
        params[:selected_id] = session["location_id"]
        session["location"] = nil
        session["location_id"] = nil
      end
    end

    def remember_location(tab, id)
      session["location"] = tab
      session["location_id"] = id
    end
  end
end
