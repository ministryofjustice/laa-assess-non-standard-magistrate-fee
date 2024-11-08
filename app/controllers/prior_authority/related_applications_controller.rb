module PriorAuthority
  class RelatedApplicationsController < PriorAuthority::BaseController
    before_action :set_default_table_sort_options, only: %i[index]

    def index
      application = PriorAuthorityApplication.find(params[:application_id])
      authorize(application, :show?)
      application_summary = BaseViewModel.build(:application_summary, application)
      editable = policy(application).update?

      model = PriorAuthority::V1::RelatedApplications.new(
        params.permit(:page, :sort_by, :sort_direction).merge(current_application_summary: application_summary)
      )
      model.execute
      @pagy = model.pagy
      @applications = model.results

      render locals: { application:, application_summary:, editable: }
    end

    private

    def set_default_table_sort_options
      @sort_by = params.fetch(:sort_by, 'date_updated')
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end
  end
end
