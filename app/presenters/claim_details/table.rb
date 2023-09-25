module ClaimDetails
  class Table
    attr_reader :details_of_claim, :defendant_details, :case_details

    def initialize(claim)
      @details_of_claim = BaseViewModel.build(:details_of_claim, claim)
      @defendant_details = BaseViewModel.build(:defendant_details, claim)
      @case_details = BaseViewModel.build(:case_details, claim)
    end

    # rubocop:disable Metrics/AbcSize
    def table
      [
        details_of_claim.rows,
        defendant_details.rows,
        case_details.rows
      ]
    end
    # rubocop:enable Metrics/AbcSize
  end
end
