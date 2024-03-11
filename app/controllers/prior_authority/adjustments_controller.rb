module PriorAuthority
  class AdjustmentsController < PriorAuthority::BaseController
    def index
      application = PriorAuthorityApplication.find(params[:application_id])
      application_summary = BaseViewModel.build(:application_summary, application)
      service_cost = BaseViewModel.build(:service_cost, application)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, application)
      editable = application_summary.can_edit?(current_user)

      @key_information = BaseViewModel.build(:key_information, application)
      render locals: { application:, application_summary:, service_cost:, core_cost_summary:, editable: }
    end
  end
end
