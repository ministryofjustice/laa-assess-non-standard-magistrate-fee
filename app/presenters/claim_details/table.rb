module ClaimDetails
  class Table
    attr_reader :claim_details

    def initialize(claim)
      @claim_details = BaseViewModel.build(:claim_details, claim)
    end

    # rubocop:disable Metrics/AbcSize
    def table
      [
        DetailsOfClaim.new(claim_details).rows,
        DefendantDetails.new(claim_details).rows,
        CaseDetails.new(claim_details).rows,
        CaseDisposal.new(claim_details).rows,
        ClaimJustification.new(claim_details).rows,
        HearingDetails.new(claim_details).rows,
        OtherInfo.new(claim_details).rows,
        ContactDetails.new(claim_details).rows
      ]
    end
    # rubocop:enable Metrics/AbcSize
  end
end
