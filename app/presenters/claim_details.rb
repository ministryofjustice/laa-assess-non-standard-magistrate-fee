module ClaimDetails
  class Table
    attr_reader :claim_details
    
    def initialize(claim)
      @claim_details = BaseViewModel.build(:claim_details, claim)
    end

    def table
      [
        { title: I18n.t('.claim_details.details_of_claim.title'), data: details_of_claim_section }
      #   {title: 'Defendant details', data: DetailsOfClaimSection },
      #   {title: 'Case details', data: DetailsOfClaimSection },
      #   {title: 'Case disposal', data: DetailsOfClaimSection },
      #   {title: 'Claim justification', data: DetailsOfClaimSection },
      #   {title: 'Claim details', data: DetailsOfClaimSection },
      #   {title: 'Hearing details', data: DetailsOfClaimSection },
      #   {title: 'Other relevant information', data: DetailsOfClaimSection },
      #   {title: 'Contact details', data: DetailsOfClaimSection },
      #   {title: 'Claim details', data: DetailsOfClaimSection }
      ]
    end

    private
    
    def details_of_claim_section
      [
        {title: I18n.t('.claim_details.details_of_claim.ufn'), value: claim_details.ufn },
        {title: I18n.t('.claim_details.details_of_claim.claim_type'), value: I18n.t(".claim_types.#{claim_details.claim_type}") },
        {title: I18n.t('.claim_details.details_of_claim.rep_order_date'), value: ApplicationController.helpers.format_date_string(claim_details.rep_order_date) }
      ]
    end
  end
end