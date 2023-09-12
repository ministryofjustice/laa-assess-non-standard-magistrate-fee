module ClaimDetails
  class ContactDetails < Base
    attr_reader :claim_details

    def initialize(claim_details)
      @claim_details = claim_details
      @key = 'contact_details'
    end

    def data
      [
        {
          title: I18n.t('.claim_details.contact_details.firm_name'),
          value: claim_details.firm_name
        },
        {
          title: I18n.t('.claim_details.contact_details.firm_account_number'),
          value: claim_details.firm_account_number
        },
        {
          title: I18n.t('.claim_details.contact_details.firm_address'),
          value: claim_details.firm_address
        },
        {
          title: I18n.t('.claim_details.contact_details.solicitor_full_name'),
          value: claim_details.solicitor_full_name
        },
        {
          title: I18n.t('.claim_details.contact_details.solicitor_ref_number'),
          value: claim_details.solicitor_ref_number
        }
      ]
    end
  end
end