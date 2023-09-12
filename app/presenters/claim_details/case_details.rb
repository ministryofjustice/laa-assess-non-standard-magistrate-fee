module ClaimDetails
  class CaseDetails < Base
    attr_reader :claim_details

    def initialize(claim_details)
      @claim_details = claim_details
      @key = 'case_details'
    end

    def data
      [
        {
          title: I18n.t('.claim_details.case_details.main_offence'),
          value: claim_details.main_offence
        },
        {
          title: I18n.t('.claim_details.case_details.main_offence_date'),
          value: ApplicationController.helpers.format_date_string(claim_details.main_offence_date)
        },
        {
          title: I18n.t('.claim_details.case_details.assigned_counsel'),
          value: claim_details.assigned_counsel&.capitalize
        },
        {
          title: I18n.t('.claim_details.case_details.unassigned_counsel'),
          value: claim_details.unassigned_counsel&.capitalize
        },
        {
          title: I18n.t('.claim_details.case_details.agent_instructed'),
          value: claim_details.agent_instructed&.capitalize
        },
        {
          title: I18n.t('.claim_details.case_details.remitted_to_magistrate'),
          value: claim_details.remitted_to_magistrate&.capitalize
        },
        {
          title: I18n.t('.claim_details.case_details.remitted_to_magistrate_date'),
          value: ApplicationController.helpers.format_date_string(claim_details.remitted_to_magistrate_date)
        }
      ]
    end
  end
end