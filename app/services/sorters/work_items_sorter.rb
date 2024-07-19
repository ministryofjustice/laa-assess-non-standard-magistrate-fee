module Sorters
  module WorkItemsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'item' => :position,
      'cost' => -> { _1.work_type.to_s },
      'date' => :completed_on,
      'fee_earner' => :fee_earner,
      'claimed_time' => :time_spent,
      'claimed_uplift' => -> { _1.uplift.to_f },
      'claimed_net_cost' => :provider_requested_amount,
      'allowed_net_cost' => -> { _1.any_adjustments? ? _1.caseworker_amount : 0 }
    }.freeze
  end
end
