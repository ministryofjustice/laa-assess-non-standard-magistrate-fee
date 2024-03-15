module PriorAuthority
  class EventsController < PriorAuthority::BaseController
    def index
      application = PriorAuthorityApplication.find(params[:application_id])
      application_summary = BaseViewModel.build(:application_summary, application)
      editable = application_summary.can_edit?(current_user)

      pagy, records = pagy(application.events.history.order(created_at: :desc))
      events = records.map { V1::EventSummary.new(event: _1) }

      render locals: { application_summary:, editable:, pagy:, events: }
    end
  end
end
