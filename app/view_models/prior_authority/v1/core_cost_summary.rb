module PriorAuthority
  module V1
    class CoreCostSummary < BaseViewModel
      attribute :application

      def additional_costs
        BaseViewModel.build(:additional_cost, application, 'additional_costs')
      end
    end
  end
end
