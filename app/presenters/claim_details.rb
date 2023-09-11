module ClaimDetails
  class Table
    attr_reader :claim_details
    
    def initialize(claim)
      @claim_details = BaseViewModel.build(:claim_details, claim)
    end

    def table
      [
        { title: I18n.t('.claim_details.details_of_claim.title'), data: details_of_claim_section },
        { title: I18n.t('.claim_details.defendant_details.title'), data: defendant_details_section },
        { title: I18n.t('.claim_details.case_details.title'), data: case_details_section },
      # {title: I18n.t('.claim_details.case_disposal.title'), data: case_disposal_section },
        {title: I18n.t('.claim_details.claim_justification.title'), data: case_justification_section },
      #   {title: 'Claim details', data: DetailsOfClaimSection },
      #   {title: 'Hearing details', data: DetailsOfClaimSection },
      #   {title: 'Other relevant information', data: DetailsOfClaimSection },
      #   {title: 'Contact details', data: DetailsOfClaimSection },
      #   {title: 'Claim details', data: DetailsOfClaimSection }
      ]
    end

    private
    
    def details_of_claim_section
      [
        { 
          title: I18n.t('.claim_details.details_of_claim.ufn'),
          value: claim_details.ufn 
        },
        { 
          title: I18n.t('.claim_details.details_of_claim.claim_type'),
          value: I18n.t(".claim_types.#{claim_details.claim_type}") 
        },
        { 
          title: I18n.t('.claim_details.details_of_claim.rep_order_date'),
          value: ApplicationController.helpers.format_date_string(claim_details.rep_order_date) 
        }
      ]
    end

    def case_details_section
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

    def case_justification_section
      [
        {
          title: I18n.t('.claim_details.claim_justification.reasons_for_claim'),
          value: reasons_for_claim
        }
      ]
    end

    def defendant_details_section
      defendant_rows.flatten
    end

    def defendant_rows
      main_defendant_rows + additional_defendant_rows 
    end

    def main_defendant_rows
      [
        { 
          title:  I18n.t('.claim_details.defendant_details.main_defendant_name'),
          value: claim_details.main_defendant_name
        },
        { 
          title: I18n.t('.claim_details.defendant_details.main_defendant_maat'),
          value: claim_details.main_defendant_maat
        }
      ] 
    end

    def additional_defendant_rows
      claim_details.additional_defendants.map.with_index do |defendant, index|
        [
          { 
            title: I18n.t('.claim_details.defendant_details.defendant_name', count: index + 1),
            value: defendant['full_name']
          },
          { 
            title: I18n.t('.claim_details.defendant_details.defendant_maat' , count: index + 1),
            value: defendant['maat']
          }
        ]
      end  
    end

    def reasons_for_claim
      reasons = claim_details.reasons_for_claim.map do |reason|
        I18n.t(".reasons_for_claim.#{reason}")
      end
      ApplicationController.helpers.sanitize(reasons.join('<br>'), tags: %w[br])
    end
  end
end