module V1
  class ClaimSummary < BaseViewModel
    include  NumberHelper
    attribute :laa_reference
    attribute :defendants
    attribute :submitted_total

    def main_defendant_name
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['full_name'] : ''
    end

    def submitted_total_pounds
      ApplicationController.helpers.pounds(submitted_total)
    end
  end
end
