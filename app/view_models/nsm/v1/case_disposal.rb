module Nsm
  module V1
    class CaseDisposal < BaseViewModel
      attribute :plea, :translated, scope: 'nsm.plea'
      attribute :plea_category, :translated, scope: 'nsm.plea_category'
      attribute :include_youth_court_fee
      attribute :include_youth_court_fee_original
      attribute :case_outcome_other_info
      attribute :cracked_trial_date
      attribute :arrest_warrant_date
      attribute :change_solicitor_date

      def key
        'case_disposal'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def youth_court_row
        return if include_youth_court_fee.nil?

        # :nocov:
        # TODO: CRM457-2306: Remove these as the fields will exist
        youth_court_included = include_youth_court_fee_original.nil? ? include_youth_court_fee : include_youth_court_fee_original
        # :nocov:
        {
          title: I18n.t('.nsm.case_disposal.additional_fee'),
          value: if youth_court_included
                   I18n.t('.nsm.case_disposal.youth_court_fee_claimed')
                 else
                   I18n.t('.nsm.case_disposal.youth_court_fee_not_claimed')
                 end
        }
      end

      def data
        [
          {
            title: plea_category.to_s,
            value:  plea.to_s == 'Other' ? "#{plea}: #{case_outcome_other_info}" : plea.to_s,
          },
          add_date_object(:cracked_trial_date),
          add_date_object(:arrest_warrant_date),
          add_date_object(:change_solicitor_date),
          youth_court_row
        ].compact
      end

      def rows
        { title:, data: }
      end

      private

      def add_date_object(value)
        date = send(value)
        return unless date

        {
          title: I18n.t(".nsm.case_disposal.#{value}"),
          value: date.to_date.to_fs(:stamp)
        }
      end
    end
  end
end
