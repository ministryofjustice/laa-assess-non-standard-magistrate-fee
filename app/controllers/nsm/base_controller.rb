module Nsm
  class BaseController < ApplicationController
    layout 'nsm'

    # rubocop:disable Metrics/AbcSize
    def remember_page(scope, tab)
      tab_name = "#{scope}_tab"
      page_number = "#{scope}_page"

      if params[:page]
        session[tab_name] = 'work_items'
        session[page_number] = params[:page]
      elsif session[tab_name] == tab
        params[:page] = session[page_number]
      else
        session[tab_name] = session[page_number] = nil
      end

      restore_location(tab)
    end
    # rubocop:enable Metrics/AbcSize

    def remember_location(tab, location_id)
      session['location'] = tab
      session['location_id'] = location_id
    end

    private

    def restore_location(tab)
      return unless tab == session['location']

      params[:selected_id] = session['location_id']
      session['location'] = nil
      session['location_id'] = nil
    end
  end
end
