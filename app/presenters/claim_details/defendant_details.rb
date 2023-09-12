module ClaimDetails
  class DefendantDetails < Base
    attr_reader :claim_details

    def initialize(claim_details)
      @claim_details = claim_details
      @key = 'defendant_details'
    end

    def data
      defendant_rows.flatten
    end
    
    private 

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
            title: I18n.t('.claim_details.defendant_details.defendant_maat', count: index + 1),
            value: defendant['maat']
          }
        ]
      end
    end
  end
end