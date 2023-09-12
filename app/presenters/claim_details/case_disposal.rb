module ClaimDetails
  class CaseDisposal < Base
    attr_reader :claim_details

    def initialize(claim_details)
      @claim_details = claim_details
      @key = 'case_disposal'
    end

    def data
      [
        {
          title: claim_details.plea_category,
          value:  claim_details.plea_en
        }
      ]
    end
  end
end
