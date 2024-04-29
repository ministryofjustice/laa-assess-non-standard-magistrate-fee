module PriorAuthority
  module V1
    class ApplicationDetails < ApplicationSummary
      attribute :prior_authority_granted, :boolean
      attribute :reason_why, :string
      attribute :supporting_documents
      attribute :next_hearing, :boolean
      attribute :next_hearing_date, :date
      attribute :client_detained, :boolean
      attribute :prison_id, :string
      attribute :custom_prison_name, :string
      attribute :subject_to_poca, :boolean
      attribute :solicitor
      attribute :plea, :string
      attribute :court_type, :string
      attribute :psychiatric_liaison, :boolean
      attribute :psychiatric_liaison_reason_not, :string
      attribute :youth_court, :boolean
      attribute :no_alternative_quote_reason, :string
      attribute :further_information_explanation, :string
      attribute :incorrect_information_explanation, :string
      attribute :updates_needed, array: true

      def overview_card
        OverviewCard.new(self)
      end

      def primary_quote_card
        PrimaryQuoteCard.new(self)
      end

      def reason_why_card
        ReasonWhyCard.new(self)
      end

      def alternative_quote_cards
        alternatives = quotes.reject { _1['primary'] }
        if alternatives.any?
          alternatives.map { AlternativeQuoteCard.new(self, Quote.new(_1)) }
        else
          [NoAlternativeQuotesCard.new(self)]
        end
      end

      def client_details_card
        ClientDetailsCard.new(self)
      end

      def next_hearing_card
        NextHearingCard.new(self)
      end

      def case_details_card
        CaseDetailsCard.new(self)
      end

      def hearing_details_card
        HearingDetailsCard.new(self)
      end

      def case_contact_card
        CaseContactCard.new(self)
      end

      def assessment_comment
        @assessment_comment ||= submission.latest_decision_event&.details&.dig('comment')
      end

      def further_information_requested?
        updates_needed.include?(SendBackForm::FURTHER_INFORMATION)
      end

      def corrections_requested?
        updates_needed.include?(SendBackForm::INCORRECT_INFORMATION)
      end

      delegate :latest_provider_update_event, to: :submission

      def provider_added_further_information?
        latest_provider_update_event.details['comment'].present?
      end

      def updated_fields
        (latest_provider_update_event.details['corrected_info'] || []).map do |section_name|
          {
            label: section_name.starts_with?('alternative_quote_') ? 'alternative_quote' : section_name,
            n: section_name.gsub('alternative_quote_', ''),
            anchor: "##{section_name == 'ufn' ? 'overview' : section_name.tr('_', '-')}"
          }
        end
      end

      def section_amended?(provider_section_name)
        latest_provider_update_event&.details&.dig('corrected_info')&.include?(provider_section_name)
      end

      def further_information_cards
        return [] unless submission.data['further_information']

        submission.data['further_information']
                  .select { _1['information_supplied'].present? }
                  .sort_by { DateTime.parse(_1['requested_at']) }
                  .reverse
                  .map do |further_information|
          FurtherInformationCard.new(self, further_information)
        end
      end
    end
  end
end
