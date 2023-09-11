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
  end
end
