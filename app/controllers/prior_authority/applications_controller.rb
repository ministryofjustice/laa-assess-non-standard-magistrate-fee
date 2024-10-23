module PriorAuthority
  class ApplicationsController < PriorAuthority::BaseController
    before_action :set_default_table_sort_options, only: %i[your open closed]
    before_action :authorize_list, only: %i[your open closed]

    def your
      return redirect_to open_prior_authority_applications_path unless policy(PriorAuthorityApplication).assign?

      @pagy, applications = order_and_paginate(PriorAuthorityApplication.open_and_assigned_to(current_user))
      @applications = applications.map do |application|
        BaseViewModel.build(:table_row, application)
      end
    end

    def open
      @pagy, applications = order_and_paginate(PriorAuthorityApplication.open)
      @applications = applications.map do |application|
        BaseViewModel.build(:table_row, application)
      end
    end

    def closed
      @pagy, applications = order_and_paginate(PriorAuthorityApplication.closed)
      @applications = applications.map do |application|
        BaseViewModel.build(:table_row, application)
      end
    end

    def show
      application = PriorAuthorityApplication.find(params[:id])
      authorize(application)
      @summary = BaseViewModel.build(:application_summary, application)
      @details = BaseViewModel.build(:application_details, application)
    end

    private

    def order_and_paginate(query)
      pagy(Sorter.call(query, @sort_by, @sort_direction))
    end

    def set_default_table_sort_options
      default = 'date_updated'
      @sort_by = params.fetch(:sort_by, default)
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end

    def submission_id
      params[:id]
    end

    def secondary_id
      nil
    end

    def authorize_list
      authorize PriorAuthorityApplication, :index?
    end
  end
end
