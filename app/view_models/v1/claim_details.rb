module V1
  class ClaimDetails < BaseViewModel
    attribute :ufn
    attribute :claim_type
    attribute :rep_order_date
    attribute :defendants

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
