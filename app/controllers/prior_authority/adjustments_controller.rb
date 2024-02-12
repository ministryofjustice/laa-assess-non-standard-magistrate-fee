module PriorAuthority
  class AdjustmentsController < PriorAuthority::BaseController
    def index
      application = AppStoreService.get(params[:application_id])
      application_summary = BaseViewModel.build(:application_summary, application)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, application)

      render locals: { application:, application_summary:, core_cost_summary: }
    end
  end
end
