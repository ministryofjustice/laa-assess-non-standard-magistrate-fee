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
          title: claim_details.category,
          value:  I18n.t(".plea_option.#{claim_details.plea}")
        }
      ]
    end
  end
end
