module ClaimDetails
  class ClaimJustification < Base
    attr_reader :claim_details

    def initialize(claim_details)
      @claim_details = claim_details
      @key = 'claim_justification'
    end

    def data
      [
        {
          title: I18n.t('.claim_details.claim_justification.reasons_for_claim'),
          value: claim_details.reasons_for_claim_list
        }
      ]
    end
  end
end