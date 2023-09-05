module V1
  class ClaimSummary < BaseViewModel
    attribute :laa_reference
    attribute :defendants

    def main_defendant_name
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['full_name'] : ''
    end
  end
end