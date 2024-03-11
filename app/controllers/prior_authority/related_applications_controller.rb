module PriorAuthority
  class RelatedApplicationsController < PriorAuthority::BaseController
    before_action :set_default_table_sort_options, only: %i[index]

    def index
      application = PriorAuthorityApplication.find(params[:application_id])
      application_summary = BaseViewModel.build(:application_summary, application)
      editable = application_summary.can_edit?(current_user)

      @pagy, records = order_and_paginate(related_applications_query_for(application))
      @applications = records.map do |record|
        BaseViewModel.build(:table_row, record)
      end

      render locals: { application:, application_summary:, editable: }
    end

    private

    def related_applications_query_for(application)
      PriorAuthorityApplication
        .related_applications(
          application.data['ufn'],
          application.data['firm_office']['account_number']
        )
        .where.not(id: application.id)
    end

    def order_and_paginate(query)
      pagy(Sorter.call(query, @sort_by, @sort_direction))
    end

    def set_default_table_sort_options
      @sort_by = params.fetch(:sort_by, 'date_created')
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end
  end
end
