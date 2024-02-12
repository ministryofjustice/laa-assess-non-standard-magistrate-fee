module PriorAuthority
  class ApplicationsController < PriorAuthority::BaseController
    def your
      applications, total = AppStoreService.list(application_type: 'crm4',
                                                 assessed: false,
                                                 assigned_user_id: current_user.id,
                                                 page: params.fetch(:page, 1),
                                                 count: 10)

      @applications = applications.map { BaseViewModel.build(:application_summary, _1) }
      @pagy = Pagy.new(count: total, page: params.fetch(:page, 1), size: 10)
    end
  end
end
