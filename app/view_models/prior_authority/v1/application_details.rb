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
      attribute :assessment_comment

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

      def further_information_requested?
        updates_needed.include?(SendBackForm::FURTHER_INFORMATION)
      end

      def corrections_requested?
        updates_needed.include?(SendBackForm::INCORRECT_INFORMATION)
      end

      def provider_added_further_information?
        submission.data['further_information'].any? { _1['new'] }
      end

      def provider_corrected_information?
        submission.data['incorrect_information'].any? { _1['new'] }
      end

      def section_amended?(provider_section_name)
        latest_incorrect_information&.dig('sections_changed')&.include?(provider_section_name)
      end

      # NOTES:
      # * Set positional values by card type for anchor links on page
      # * relies on sort by honouring original ordering in sort key matches
      #   i.e. [[1, :a], [2, :a], [1, :b], [2, :b]].sort_by(&:first) => [[1, :a], [1, :b], [2, :a], [2, :b]]
      def information_cards
        @information_cards ||= begin
          positions = Hash.new(0)
          (incorrect_information_cards + further_information_cards).sort_by(&:requested_at)
                                                                   .reverse
                                                                   .map { |card| [card, positions[card.class] += 1] }
        end
      end

      def further_information_cards
        return [] unless submission.data['further_information']

        submission.data['further_information']
                  .select { _1['information_supplied'].present? }
                  .map do |further_information|
          FurtherInformationCard.new(self, further_information)
        end
      end

      def incorrect_information_cards
        return [] unless submission.data['incorrect_information']

        submission.data['incorrect_information']
                  .select { _1['sections_changed'].present? }
                  .map do |incorrect_information|
          IncorrectInformationCard.new(self, incorrect_information)
        end
      end

      def latest_incorrect_information
        submission.data['incorrect_information']&.max_by { DateTime.parse(_1['requested_at']) }
      end
    end
  end
end
