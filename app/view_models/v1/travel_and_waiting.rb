module V1
  class TravelAndWaiting < BaseViewModel
    include V1::WorkItemSummary

    INCLUDED_TYPES = %w[travel waiting].freeze

    attribute :claim
    attribute :firm_office

    def vat_registered?
      firm_office['vat_registered'] == 'yes'
    end

    def table_fields
      work_item_data.map do |work_type, requested_cost, requested_time, allowed_cost, allowed_time|
        [
          work_type,
          format_period(requested_time, style: :long),
          NumberTo.pounds(requested_cost),
          format_period(allowed_time, style: :long),
          NumberTo.pounds(allowed_cost),
        ]
      end
    end

    def total_cost
      NumberTo.pounds(
        work_item_data.sum { |_, _, _, total_cost, _| total_cost }
      )
    end

    delegate :any?, to: :work_item_data

    private

    def skip_work_item?(work_item)
      INCLUDED_TYPES.exclude?(work_item.work_type.value)
    end
  end
end
