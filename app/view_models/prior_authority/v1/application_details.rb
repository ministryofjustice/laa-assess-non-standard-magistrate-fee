module PriorAuthority
  module V1
    class ApplicationDetails < ApplicationSummary
      attribute :ufn, :string
      attribute :prison_law, :boolean
      attribute :prior_authority_granted, :boolean
      attribute :reason_why, :string
      attribute :supporting_documents
      attribute :next_hearing, :boolean
      attribute :next_hearing_date, :date
      attribute :client_detained, :boolean
      attribute :subject_to_poca, :boolean
      attribute :main_offence, :string
      attribute :solicitor
      attribute :plea, :string
      attribute :court_type, :string
      attribute :psychiatric_liaison, :boolean
      attribute :psychiatric_liaison_reason_not, :string
      attribute :youth_court, :boolean

      def overview_card
        OverviewCard.new(self)
      end

      def primary_quote_card
        PrimaryQuoteCard.new(self)
      end

      def reason_why_card
        ReasonWhyCard.new(self)
      end

      def alternative_quotes
        quotes.reject { _1['primary'] }.map { Quote.new(_1.merge(item_type:)) }
      end

      def alternative_quote_card(alternative_quote)
        AlternativeQuoteCard.new(self, alternative_quote)
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
    end
  end
end
