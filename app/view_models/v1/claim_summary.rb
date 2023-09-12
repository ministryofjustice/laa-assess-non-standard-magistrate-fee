module V1
  class ClaimSummary < BaseViewModel
    include NumberHelper
    attribute :laa_reference
    attribute :defendants
    attribute :submitted_total
    attribute :adjusted_total

    def main_defendant_name
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['full_name'] : ''
    end

    def total
      if adjusted_total.present?
        ApplicationController.helpers.pounds(adjusted_total)
      elsif submitted_total.present?
        ApplicationController.helpers.pounds(submitted_total)

      end
    end
  end
end
