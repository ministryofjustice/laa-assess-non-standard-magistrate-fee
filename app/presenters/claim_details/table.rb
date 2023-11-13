module ClaimDetails
  class Table
    attr_reader :details_of_claim, :defendant_details,
                :case_details, :case_disposal, :claim_justification,
                :hearing_details, :contact_details, :other_info,
                :claim_details, :equality_details

    def initialize(claim)
      @details_of_claim = BaseViewModel.build(:details_of_claim, claim)
      @defendant_details = BaseViewModel.build(:defendant_details, claim)
      @case_details = BaseViewModel.build(:case_details, claim)
      @case_disposal = BaseViewModel.build(:case_disposal, claim)
      @claim_justification = BaseViewModel.build(:claim_justification, claim)
      @claim_details = BaseViewModel.build(:claim_details, claim)
      @hearing_details = BaseViewModel.build(:hearing_details, claim)
      @other_info = BaseViewModel.build(:other_info, claim)
      @contact_details = BaseViewModel.build(:contact_details, claim)
      @equality_details = BaseViewModel.build(:equality_details, claim)
    end

    def table
      [
        details_of_claim.rows,
        defendant_details.rows,
        case_details.rows,
        case_disposal.rows,
        claim_justification.rows,
        claim_details.rows,
        hearing_details.rows,
        other_info.rows,
        contact_details.rows,
        equality_details.rows,
      ]
    end
  end
end
