module Nsm
  module V1
    class DetailsOfClaim < BaseViewModel
      attribute :ufn
      attribute :claim_type, :translated, scope: 'nsm.claim_type'
      attribute :rep_order_date
      attribute :cntp_order
      attribute :cntp_date
      attribute :stage_reached
      attribute :firm_office

      def key
        'details_of_claim'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def firm_account_number
        firm_office['account_number']
      end

      def data
        first_rows + middle_rows + final_rows
      end

      def first_rows
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.ufn"),
            value: ufn
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.claim_type"),
            value:  claim_type.to_s
          },
        ]
      end

      def middle_rows
        if claim_type.value == 'breach_of_injunction'
          breach_rows
        else
          magistrates_rows
        end
      end

      def magistrates_rows
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.rep_order_date"),
            value: format_in_zone(rep_order_date)
          },
        ]
      end

      def breach_rows
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.cntp_order"),
            value: cntp_order
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.cntp_date"),
            value: format_in_zone(cntp_date)
          }
        ]
      end

      def final_rows
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.stage_reached"),
            value: I18n.t(".nsm.claim_details.#{key}.stages.#{stage_reached}")
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.firm_account_number"),
            value: firm_account_number
          },
        ]
      end

      def rows
        { title:, data: }
      end
    end
  end
end
