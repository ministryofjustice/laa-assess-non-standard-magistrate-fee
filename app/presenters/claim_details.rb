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
      #   {title: 'Case details', data: DetailsOfClaimSection },
      #   {title: 'Case disposal', data: DetailsOfClaimSection },
      #   {title: 'Claim justification', data: DetailsOfClaimSection },
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

    def defendant_details_section
      defendant_rows.flatten
    end

    def defendant_rows
      binding.pry
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
  end
end