module ClaimDetails
  class DetailsOfClaim < Base
    attr_reader :claim_details

    def initialize(claim_details)
      @claim_details = claim_details
      @key = 'details_of_claim'
    end

    # rubocop:disable Metrics/MethodLength
    def data
      [
        {
          title: I18n.t('.claim_details.details_of_claim.ufn'),
          value: claim_details.ufn
        },
        {
          title: I18n.t('.claim_details.details_of_claim.claim_type'),
          value: claim_details.claim_type_en
        },
        {
          title: I18n.t('.claim_details.details_of_claim.rep_order_date'),
          value: ApplicationController.helpers.format_date_string(claim_details.rep_order_date)
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength
  end
end
