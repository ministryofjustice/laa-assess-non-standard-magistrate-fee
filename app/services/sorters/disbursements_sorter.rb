module Sorters
  module DisbursementsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'item' => :position,
      'cost' => -> { _1.type_name.to_s },
      'date' => :disbursement_date,
      'claimed_net' => :original_total_cost_without_vat,
      'claimed_vat' => :original_vat_amount,
      'claimed_gross' => :provider_requested_total_cost,
      'allowed_gross' => -> { _1.any_adjustments? ? _1.caseworker_total_cost : 0 }
    }.freeze
  end
end
