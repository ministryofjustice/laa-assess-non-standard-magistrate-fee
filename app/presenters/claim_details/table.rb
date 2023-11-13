module ClaimDetails
  class Table
    attr_reader :claim

    def initialize(claim)
      @claim = claim
    end

    def table
      [
        details_of_claim,
        defendant_details,
        case_details,
        case_disposal,
        claim_justification,
        claim_details,
        hearing_details,
        other_info,
        contact_details,
        equality_details,
      ].map(&:rows)
    end

    private

    def details_of_claim
      BaseViewModel.build(:details_of_claim, claim)
    end

    def defendant_details
      BaseViewModel.build(:defendant_details, claim)
    end

    def case_details
      BaseViewModel.build(:case_details, claim)
    end

    def case_disposal
      BaseViewModel.build(:case_disposal, claim)
    end

    def claim_justification
      BaseViewModel.build(:claim_justification, claim)
    end

    def claim_details
      BaseViewModel.build(:claim_details, claim)
    end

    def hearing_details
      BaseViewModel.build(:hearing_details, claim)
    end

    def other_info
      BaseViewModel.build(:other_info, claim)
    end

    def contact_details
      BaseViewModel.build(:contact_details, claim)
    end

    def equality_details
      BaseViewModel.build(:equality_details, claim)
    end
  end
end
