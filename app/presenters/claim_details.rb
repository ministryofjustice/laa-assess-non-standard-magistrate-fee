module ClaimDetails
  class Table
    attr_reader :claim
    
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
        {title: I18n.t('.claim_details.details_of_claim.ufn'), value: "abc" },
        {title: I18n.t('.claim_details.details_of_claim.claim_type'), value: "abc" }
      ]
    end
  end
end