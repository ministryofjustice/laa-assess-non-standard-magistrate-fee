module V1
  class ClaimDetails < BaseViewModel
    attribute :ufn
    attribute :claim_type
    attribute :rep_order_date
    attribute :defendants
    attribute :main_offence
    attribute :main_offence_date
    attribute :assigned_counsel
    attribute :unassigned_counsel
    attribute :agent_instructed
    attribute :remitted_to_magistrate
    attribute :remitted_to_magistrate_date
    attribute :reasons_for_claim
    attribute :first_hearing_date
    attribute :number_of_hearing
    attribute :court
    attribute :in_area
    attribute :youth_count
    attribute :hearing_outcome
    attribute :matter_type
    attribute :is_other_info
    attribute :other_info
    attribute :concluded
    attribute :conclusion
    attribute :firm_office
    attribute :solicitor
    attribute :plea
    attribute :plea_category

    def claim_type_en
      claim_type['en']
    end

    def matter_type_en
      matter_type['en']
    end

    def hearing_outcome_en
      hearing_outcome['en']
    end

    def main_defendant_name
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['full_name'] : ''
    end

    def main_defendant_maat
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['maat'] : ''
    end

    def additional_defendants
      defendants.reject { |defendant| defendant['main'] == true }
    end

    def firm_name
      firm_office['name']
    end

    def firm_account_number
      firm_office['account_number']
    end

    def solicitor_full_name
      solicitor['full_name']
    end

    def solicitor_ref_number
      solicitor['reference_number']
    end

    def firm_address
      ApplicationController.helpers.sanitize([
        firm_office['address_line_1'],
        firm_office['address_line_2'],
        firm_office['town'],
        firm_office['postcode']
      ].join('<br>'),
                                             tags: %w[br])
    end

    def reasons_for_claim_list
      reasons = reasons_for_claim.pluck('en')
      ApplicationController.helpers.sanitize(reasons.join('<br>'), tags: %w[br])
    end
  end
end
