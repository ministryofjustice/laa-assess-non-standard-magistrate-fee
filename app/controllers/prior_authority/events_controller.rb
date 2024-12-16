module PriorAuthority
  class EventsController < PriorAuthority::BaseController
    def index
      application = PriorAuthorityApplication.load_from_app_store(params[:application_id])
      authorize(application, :show?)
      application_summary = BaseViewModel.build(:application_summary, application)
      editable = policy(application).update?

      pagy, records = pagy_array(application.events.sort_by(&:created_at).reverse)
      events = records.map { V1::EventSummary.new(event: _1) }

      render locals: { application_summary:, editable:, pagy:, events: }
    end
  end
end
