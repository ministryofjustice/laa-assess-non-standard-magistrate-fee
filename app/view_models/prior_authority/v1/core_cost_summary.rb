module PriorAuthority
  module V1
    class CoreCostSummary < BaseViewModel
      attribute :submission

      def additional_costs
        BaseViewModel.build(:additional_cost, submission, 'additional_costs')
      end
    end
  end
end
